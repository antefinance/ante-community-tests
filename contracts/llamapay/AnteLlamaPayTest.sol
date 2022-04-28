// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// https://.etherscan.io/address/[CONTRACT_ADDRESS]#readContract to check
// https://.etherscan.io/address/[CONTRACT_ADDRESS]#writeContract to set values

pragma solidity ^0.8.0;

import {AnteTest} from "../AnteTest.sol";
import {LlamaPayFactory} from "./interfaces/LlamaPayFactory.sol";
import {LlamaPay} from "./interfaces/LlamaPay.sol";

/// @title  LlamaPay never goes backwards in time test
/// @notice Ante Test to check that lastPayerUpdate <= block.timestamp holds for any LlamaPay payer/token
///         Uses the setter functions provided to set the addresses of the LlamaPay instance and payer address to check
///         if 0x0 is passed as the LlamaPay address, will check through all LlamaPay contracts in the factory
///         otherwise, will check for the single LlamaPay instance provided
///         Note: may no longer hold after 231,800 A.D. due to holding timestamp in uint40
contract AnteLlamaPayTest is
    AnteTest("LlamaPay never pays future payments early (lastPayerUpdate[anyone] <= block.timestamp)")
{
    LlamaPayFactory internal factory;

    address public tokenAddress;
    address public payerAddress;

    constructor(address _llamaPayFactoryAddress) {
        factory = LlamaPayFactory(_llamaPayFactoryAddress);

        protocolName = "LlamaPay"; // <3
        testedContracts.push(_llamaPayFactoryAddress);
        testedContracts.push(address(0)); // test all llamapay instances by default
    }

    /// @notice checks that lastPayerUpdate <= block.timestamp for a given payer in a given LlamaPay instance
    /// @param llamaPayContractAddress address of specific LlamaPay instance to check
    /// @return true if lastPayerUpdate[payer] <= block.timestamp
    function checkSingle(address llamaPayContractAddress) public view returns (bool) {
        (uint40 lastPayerUpdate, ) = LlamaPay(llamaPayContractAddress).payers(payerAddress);

        // even if payer is not in the payer list for this LlamaPay instance, will return true (lastPayerUpdate = 0)
        return (lastPayerUpdate <= block.timestamp);
    }

    /// @notice Checks that lastPayerUpdate[payer] <= block.timestamp for a given payer and LlamaPay contract(s)
    ///         Uses the setter functions provided to set the token addresses and payer address to check
    ///         if 0x0 is passed as token address, will check through all LlamaPay contracts in factory
    ///         otherwise, will check for the single LlamaPay instance provided
    /// @return true if lastPayerUpdate[payer] <= block.timestamp for all LlamaPay contracts checked
    function checkTestPasses() external view override returns (bool) {
        // if a valid token is specified, check payer for specific token llamapay contract

        (address predictedAddress, bool isDeployed) = factory.getLlamaPayContractByToken(tokenAddress);
        if (isDeployed) {
            return checkSingle(predictedAddress);
        }

        // otherwise, if token address is 0x0, loop all tokens in llamapay factory
        for (uint256 i = 0; i < factory.getLlamaPayContractCount(); i++) {
            // if any llamapay instance fails, fail the test
            if (checkSingle(factory.getLlamaPayContractByIndex(i)) == false) {
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
        // TODO might be more thorough to loop through llamapay contracts and verify that at least one
        // instance of a valid payer mapping exists. but also an invalid payer address doesn't fail
        // the test so no risk of false positive
        payerAddress = _payerAddress;
    }

    /// @notice Sets the token address of the LlamaPay instance for the Ante Test to check
    /// @param _tokenAddress address of token to check LlamaPay instance for. If 0x0 is set,
    ///         the Ante Test will check all LlamaPay instances
    function setTokenAddress(address _tokenAddress) external {
        //check that token address exists in llamapayfactory list but allow 0x0 (all)
        if (_tokenAddress != address(0)) {
            (, bool isDeployed) = factory.getLlamaPayContractByToken(_tokenAddress);
            require(isDeployed, "LlamaPay contract for given token does not yet exist");
        }

        tokenAddress = _tokenAddress;
        require(testedContracts.length == 2, "Somehow more contracts were added");
        testedContracts[1] = _tokenAddress;
    }

    /// @notice Sets both the token address of the LlamaPay instance and the payer address
    ///         for the Ante Test to check
    /// @param _tokenAddress address of token to check LlamaPay instance for. If 0x0 is set,
    ///         the Ante Test will check all LlamaPay instances
    /// @param _payerAddress address of payer to check
    function setTokenAndPayerAddress(address _tokenAddress, address _payerAddress) external {
        //check that token address exists in llamapayfactory list but allow 0x0 (all)
        if (_tokenAddress != address(0)) {
            (, bool isDeployed) = factory.getLlamaPayContractByToken(_tokenAddress);
            require(isDeployed, "LlamaPay contract for given token does not yet exist");
        }

        tokenAddress = _tokenAddress;
        payerAddress = _payerAddress;
        require(testedContracts.length == 2, "Somehow more contracts were added");
        testedContracts[1] = _tokenAddress;
    }
}
