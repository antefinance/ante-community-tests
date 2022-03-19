// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {LlamaPayFactory} from "./interfaces/LlamaPayFactory.sol";
import {LlamaPay} from "./interfaces/LlamaPay.sol";

/// @title  LlamaPay never
/// @notice Ante Test to check ...
/// may no longer hold after 231,800 A.D.
contract AnteLlamaPayTest is AnteTest("Ante LlamaPay Test") {
    LlamaPayFactory internal factory;

    address public tokenAddress;
    address public payerAddress;

    constructor(address _llamaPayFactoryAddress) {
        factory = LlamaPayFactory(_llamaPayFactoryAddress);

        protocolName = "LlamaPay"; // <3
        testedContracts = [_llamaPayFactoryAddress];
    }

    /// @notice checks that lastPayerUpdate <= block.timestamp for a given payer in a given LlamaPay instance
    /// @param payContractAddress address of specific LlamaPay instance to check
    /// @return true if lastPayerUpdate[payer] <= block.timestamp
    function checkSingle(address payContractAddress) public view returns (bool) {
        (uint40 lastPayerUpdate, ) = LlamaPay(payContractAddress).payers(payerAddress);

        // even if payer is not in the payer list for this LlamaPay instance, will return true (lastPayerUpdate = 0)
        return (lastPayerUpdate <= block.timestamp);
    }

    /// @notice Checks that lastPayerUpdate[payer] <= block.timestamp for a given payer and LlamaPay contract(s)
    ///         Uses the setter functions provided to set the token addresses and payer address to check
    ///         if 0x0 is passed as token address, will check through all LlamaPay contracts in factory
    ///         otherwise, will check for a the single LlamaPay instance provided
    /// @return true if lastPayerUpdate[payer] <= block.timestamp for all LlamaPay contracts checked
    function checkTestPasses() external view override returns (bool) {
        // if a valid token is specified, check payer for specific token llamapay contract
        if (tokenAddress != address(0)) {
            // TestSetter already checks tokenAddress in payContracts
            return checkSingle(factory.payContracts(tokenAddress));
        }

        // otherwise, if token address is 0x0, loop all tokens in llamapay factory
        for (uint256 i = 0; i < factory.payContractsArrayLength(); i++) {
            // if any llamapay instance fails, fail the test
            if (checkSingle(factory.payContractsArray(i)) == false) {
                return false;
            }
        }

        return true;
    }

    /*****************************************************
     * ================ USER INTERFACE ================= *
     *****************************************************/

    /// @notice Sets the payer address for the Ante Test to check
    /// @param _payerAddress address of payer to check
    function setPayerAddress(address _payerAddress) external {
        //check that payer address is valid? is there a way to do this without getting expensive?
        require(_payerAddress != address(0), "Invalid payer address");
        // TODO would be more thorough to loop through llamapay contracts and verify that at least one
        // instance of a valid payer mapping exists

        payerAddress = _payerAddress;
    }

    /// @notice Sets the token address of the LlamaPay instance for the Ante Test to check
    /// @param _tokenAddress address of token to check LlamaPay instance for. If 0x0 is set,
    ///         the Ante Test will check all LlamaPay instances
    function setTokenAddress(address _tokenAddress) external {
        //check that token address exists in llamapayfactory list but allow 0x0 (all)
        if (_tokenAddress != address(0)) {
            require(
                factory.payContracts(_tokenAddress) != address(0),
                "LlamaPay contract for given token does not exist"
            );
        }

        tokenAddress = _tokenAddress;
    }
}
