//SPDX-License-Identifier: None
//FROM https://github.com/LlamaPay/llamapay/blob/9b01a5e74229b39f3d782b86fc01ff39d8728dcf/contracts/LlamaPay.sol
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {BoringBatchable} from "./fork/BoringBatchable.sol";

interface Factory {
    function parameter() external view returns (address);
}

interface IERC20WithDecimals {
    function decimals() external view returns (uint8);
}

// All amountPerSec and all internal numbers use 20 decimals, these are converted to the right decimal on withdrawal/deposit
// The reason for that is to minimize precision errors caused by integer math on tokens with low decimals (eg: USDC)

// Invariant through the whole contract: lastPayerUpdate[anyone] <= block.timestamp
// Reason: timestamps can't go back in time (https://github.com/ethereum/go-ethereum/blob/master/consensus/ethash/consensus.go#L274 and block timestamp definition on ethereum's yellow paper)
// and we always set lastPayerUpdate[anyone] either to the current block.timestamp or a value lower than it
// We could use this to optimize subtractions and avoid an unneded safemath check there for some gas savings
// However this is obscure enough that we are not sure if a future ethereum network upgrade might remove this assertion
// or if an ethereum fork might remove that code and invalidate the condition, causing our deployment on that chain to be vulnerable
// This is dangerous because if someone can make a timestamp go back into the past they could steal all the money
// So we forgo these optimizations and instead enforce this condition.

// Another assumption is that all timestamps can fit in uint40, this will be true until year 231,800, so it's a safe assumption

contract LlamaPay is BoringBatchable {
    using SafeERC20 for IERC20;

    struct Payer {
        uint40 lastPayerUpdate;
        uint216 totalPaidPerSec; // uint216 is enough to hold 1M streams of 3e51 tokens/yr, which is enough
    }

    mapping(bytes32 => uint256) public streamToStart;
    mapping(address => Payer) public payers;
    mapping(address => uint256) public balances; // could be packed together with lastPayerUpdate but gains are not high
    IERC20 public token;
    uint256 public DECIMALS_DIVISOR;

    event StreamCreated(address indexed from, address indexed to, uint216 amountPerSec, bytes32 streamId);
    event StreamCancelled(address indexed from, address indexed to, uint216 amountPerSec, bytes32 streamId);
    event StreamModified(
        address indexed from,
        address indexed oldTo,
        uint216 oldAmountPerSec,
        bytes32 oldStreamId,
        address indexed to,
        uint216 amountPerSec,
        bytes32 newStreamId
    );
    event Withdraw(address indexed from, address indexed to, uint216 amountPerSec, bytes32 streamId, uint256 amount);

    constructor() {
        token = IERC20(Factory(msg.sender).parameter());
        uint8 tokenDecimals = IERC20WithDecimals(address(token)).decimals();
        DECIMALS_DIVISOR = 10**(20 - tokenDecimals);
    }

    function getStreamId(
        address from,
        address to,
        uint216 amountPerSec
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(from, to, amountPerSec));
    }

    function _createStream(address to, uint216 amountPerSec) internal returns (bytes32 streamId) {
        streamId = getStreamId(msg.sender, to, amountPerSec);
        require(amountPerSec > 0, "amountPerSec can't be 0");
        require(streamToStart[streamId] == 0, "stream already exists");
        streamToStart[streamId] = block.timestamp;

        Payer storage payer = payers[msg.sender];
        uint256 totalPaid;
        uint256 delta = block.timestamp - payer.lastPayerUpdate;
        unchecked {
            totalPaid = delta * uint256(payer.totalPaidPerSec);
        }
        balances[msg.sender] -= totalPaid; // implicit check that balance >= totalPaid, can't create a new stream unless there's no debt

        payer.lastPayerUpdate = uint40(block.timestamp);
        payer.totalPaidPerSec += amountPerSec;

        // checking that no overflow will ever happen on totalPaidPerSec is important because if there's an overflow later:
        //   - if we don't have overflow checks -> it would be possible to steal money from other people
        //   - if there are overflow checks -> money will be stuck forever as all txs (from payees of the same payer) will revert
        //     which can be used to rug employees and make them unable to withdraw their earnings
        // Thus it's extremely important that no user is allowed to enter any value that later on could trigger an overflow.
        // We implicitly prevent this here because amountPerSec/totalPaidPerSec is uint216 and is only ever multiplied by timestamps
        // which will always fit in a uint40. Thus the result of the multiplication will always fit inside a uint256 and never overflow
        // This however introduces a new invariant: the only operations that can be done with amountPerSec/totalPaidPerSec are muls against timestamps
        // and we need to make sure they happen in uint256 contexts, not any other
    }

    function createStream(address to, uint216 amountPerSec) public {
        bytes32 streamId = _createStream(to, amountPerSec);
        emit StreamCreated(msg.sender, to, amountPerSec, streamId);
    }

    /*
        proof that lastUpdate < block.timestamp:
        let's start by assuming the opposite, that lastUpdate > block.timestamp, and then we'll prove that this is impossible
        lastUpdate > block.timestamp
            -> timePaid = lastUpdate - lastPayerUpdate[from] > block.timestamp - lastPayerUpdate[from] = payerDelta
            -> timePaid > payerDelta
            -> payerBalance = timePaid * totalPaidPerSec[from] > payerDelta * totalPaidPerSec[from] = totalPayerPayment
            -> payerBalance > totalPayerPayment
        but this last statement is impossible because if it were true we'd have gone into the first if branch!
    */
    /*
        proof that totalPaidPerSec[from] != 0:
        totalPaidPerSec[from] is a sum of uint that are different from zero (since we test that on createStream())
        and we test that there's at least one stream active with `streamToStart[streamId] != 0`,
        so it's a sum of one or more elements that are higher than zero, thus it can never be zero
    */

    // Make it possible to withdraw on behalf of others, important for people that don't have a metamask wallet (eg: cex address, trustwallet...)
    function _withdraw(
        address from,
        address to,
        uint216 amountPerSec
    )
        private
        returns (
            uint40 lastUpdate,
            bytes32 streamId,
            uint256 amountToTransfer
        )
    {
        streamId = getStreamId(from, to, amountPerSec);
        require(streamToStart[streamId] != 0, "stream doesn't exist");

        Payer storage payer = payers[from];
        uint256 totalPayerPayment;
        uint256 payerDelta = block.timestamp - payer.lastPayerUpdate;
        unchecked {
            totalPayerPayment = payerDelta * uint256(payer.totalPaidPerSec);
        }
        uint256 payerBalance = balances[from];
        if (payerBalance >= totalPayerPayment) {
            unchecked {
                balances[from] = payerBalance - totalPayerPayment;
            }
            lastUpdate = uint40(block.timestamp);
        } else {
            // invariant: totalPaidPerSec[from] != 0
            unchecked {
                uint256 timePaid = payerBalance / uint256(payer.totalPaidPerSec);
                lastUpdate = uint40(payer.lastPayerUpdate + timePaid);
                // invariant: lastUpdate < block.timestamp (we need to maintain it)
                balances[from] = payerBalance % uint256(payer.totalPaidPerSec);
            }
        }
        uint256 delta = lastUpdate - streamToStart[streamId]; // Could use unchecked here too I think
        unchecked {
            // We push transfers to be done outside this function and at the end of public functions to avoid reentrancy exploits
            amountToTransfer = (delta * uint256(amountPerSec)) / DECIMALS_DIVISOR;
        }
        emit Withdraw(from, to, amountPerSec, streamId, amountToTransfer);
    }

    // Copy of _withdraw that is view-only and returns how much can be withdrawn from a stream, purely for convenience on frontend
    // No need to review since this does nothing
    function withdrawable(
        address from,
        address to,
        uint216 amountPerSec
    )
        external
        view
        returns (
            uint256 withdrawableAmount,
            uint256 lastUpdate,
            uint256 owed
        )
    {
        bytes32 streamId = getStreamId(from, to, amountPerSec);
        require(streamToStart[streamId] != 0, "stream doesn't exist");

        Payer storage payer = payers[from];
        uint256 totalPayerPayment;
        uint256 payerDelta = block.timestamp - payer.lastPayerUpdate;
        unchecked {
            totalPayerPayment = payerDelta * uint256(payer.totalPaidPerSec);
        }
        uint256 payerBalance = balances[from];
        if (payerBalance >= totalPayerPayment) {
            lastUpdate = block.timestamp;
        } else {
            unchecked {
                uint256 timePaid = payerBalance / uint256(payer.totalPaidPerSec);
                lastUpdate = payer.lastPayerUpdate + timePaid;
            }
        }
        uint256 delta = lastUpdate - streamToStart[streamId];
        withdrawableAmount = (delta * uint256(amountPerSec)) / DECIMALS_DIVISOR;
        owed = ((block.timestamp - lastUpdate) * uint256(amountPerSec)) / DECIMALS_DIVISOR;
    }

    function withdraw(
        address from,
        address to,
        uint216 amountPerSec
    ) external {
        (uint40 lastUpdate, bytes32 streamId, uint256 amountToTransfer) = _withdraw(from, to, amountPerSec);
        streamToStart[streamId] = lastUpdate;
        payers[from].lastPayerUpdate = lastUpdate;
        token.safeTransfer(to, amountToTransfer);
    }

    function _cancelStream(address to, uint216 amountPerSec) internal returns (bytes32 streamId) {
        uint40 lastUpdate;
        uint256 amountToTransfer;
        (lastUpdate, streamId, amountToTransfer) = _withdraw(msg.sender, to, amountPerSec);
        streamToStart[streamId] = 0;
        Payer storage payer = payers[msg.sender];
        unchecked {
            // totalPaidPerSec is a sum of items which include amountPerSec, so totalPaidPerSec >= amountPerSec
            payer.totalPaidPerSec -= amountPerSec;
        }
        payer.lastPayerUpdate = lastUpdate;
        token.safeTransfer(to, amountToTransfer);
    }

    function cancelStream(address to, uint216 amountPerSec) public {
        bytes32 streamId = _cancelStream(to, amountPerSec);
        emit StreamCancelled(msg.sender, to, amountPerSec, streamId);
    }

    function modifyStream(
        address oldTo,
        uint216 oldAmountPerSec,
        address to,
        uint216 amountPerSec
    ) external {
        // Can be optimized but I don't think extra complexity is worth it
        bytes32 oldStreamId = _cancelStream(oldTo, oldAmountPerSec);
        bytes32 newStreamId = _createStream(to, amountPerSec);
        emit StreamModified(msg.sender, oldTo, oldAmountPerSec, oldStreamId, to, amountPerSec, newStreamId);
    }

    function deposit(uint256 amount) public {
        balances[msg.sender] += amount * DECIMALS_DIVISOR;
        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    function depositAndCreate(
        uint256 amountToDeposit,
        address to,
        uint216 amountPerSec
    ) external {
        deposit(amountToDeposit);
        createStream(to, amountPerSec);
    }

    function withdrawPayer(uint256 amount) public {
        Payer storage payer = payers[msg.sender];
        balances[msg.sender] -= amount; // implicit check that balance > amount
        uint256 delta = block.timestamp - payer.lastPayerUpdate;
        unchecked {
            require(balances[msg.sender] >= delta * uint256(payer.totalPaidPerSec), "pls no rug");
            token.safeTransfer(msg.sender, amount / DECIMALS_DIVISOR);
        }
    }

    function withdrawPayerAll() external {
        Payer storage payer = payers[msg.sender];
        unchecked {
            uint256 delta = block.timestamp - payer.lastPayerUpdate;
            // Just helper function, nothing happens if number is wrong
            // If there's an overflow it's just equivalent to calling withdrawPayer() directly with a big number
            withdrawPayer(balances[msg.sender] - delta * uint256(payer.totalPaidPerSec));
        }
    }

    function getPayerBalance(address payerAddress) external view returns (int256) {
        Payer storage payer = payers[payerAddress];
        int256 balance = int256(balances[payerAddress]);
        uint256 delta = block.timestamp - payer.lastPayerUpdate;
        return (balance - int256(delta * uint256(payer.totalPaidPerSec))) / int256(DECIMALS_DIVISOR);
    }
}
