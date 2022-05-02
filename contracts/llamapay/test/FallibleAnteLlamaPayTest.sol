// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Test harness for AnteLlamaPayTest that makes it easy to fail test. DO NOT DEPLOY

pragma solidity ^0.7.0;

import "../../AnteTest.sol";

interface ILlamaPayFactory {
    function getLlamaPayContractCount() external view returns (uint256);

    function getLlamaPayContractByIndex(uint256 i) external view returns (address);

    function getLlamaPayContractByToken(address _token) external view returns (address, bool);
}

interface ILlamaPay {
    function payers(address _payer) external view returns (uint40, uint216);
}

/// @title  LlamaPay never goes backwards in time test
/// @notice Ante Test to check that lastPayerUpdate <= block.timestamp holds
///         for any LlamaPay payer/token. Uses the setter functions provided to
///         set the addresses of the LlamaPay instance and payer address to
///         check. If 0x0 is passed as the LlamaPay address, will check through
///         all LlamaPay contracts in the factory. Otherwise, will check for
///         the single LlamaPay instance provided
///         Note: may no longer hold after 231,800 A.D. due to holding timestamp in uint40
contract FallibleAnteLlamaPayTest is AnteTest("FALLIBLE LlamaPay Ante Test") {
    // https://etherscan.io/address/0xde1C04855c2828431ba637675B6929A684f84C7F
    ILlamaPayFactory internal factory;

    address public tokenAddress;
    address public payerAddress;
    bool public forceFailure; // MOCK VARIABLE

    constructor(address _llamaPayFactoryAddress) {
        factory = ILlamaPayFactory(_llamaPayFactoryAddress);
        forceFailure = false;

        protocolName = "LlamaPay"; // <3
        testedContracts.push(_llamaPayFactoryAddress);
        testedContracts.push(address(0)); // test all LlamaPay instances by default
    }

    /// @notice mock function that allows triggering test failure
    function toggleFailure() external {
        forceFailure = !forceFailure;
    }

    /// @notice checks that lastPayerUpdate <= block.timestamp for a given
    ///         payer in a given LlamaPay instance
    /// @param llamaPayAddress address of specific LlamaPay instance to check
    /// @return true if lastPayerUpdate[payer] <= block.timestamp
    function checkSingle(address llamaPayAddress) internal view returns (bool) {
        (uint40 lastPayerUpdate, ) = ILlamaPay(llamaPayAddress).payers(payerAddress);

        // We don't need to worry about checking if the payer exists in the
        // payer mapping for this LlamaPay instance since 0 < block.timestamp
        return (lastPayerUpdate <= block.timestamp);
    }

    /// @notice If forceFailure is set, fails the test. Otherwise,
    ///         checks that lastPayerUpdate[payer] <= block.timestamp for a
    ///         given payer and LlamaPay contract(s). Uses the setter functions
    ///         provided to set the token addresses and payer address to check
    ///         if 0x0 is passed as token address, will check through all
    ///         LlamaPay contracts in factory. otherwise, will check for the
    ///         single LlamaPay instance provided
    /// @return true if lastPayerUpdate[payer] <= block.timestamp for all LlamaPay contracts checked
    function checkTestPasses() external view override returns (bool) {
        // If forceFailure set, fails test
        if (forceFailure) return false;

        // If a valid token is specified, check payer for specific LlamaPay contract
        (address predictedAddress, bool isDeployed) = factory.getLlamaPayContractByToken(tokenAddress);
        if (isDeployed) {
            return checkSingle(predictedAddress);
        }

        // Otherwise, if token address is 0x0, loop through all LlamaPay instances
        for (uint256 i = 0; i < factory.getLlamaPayContractCount(); i++) {
            // If any LlamaPay instance fails, fail the test
            if (!checkSingle(factory.getLlamaPayContractByIndex(i))) {
                return false;
            }
        }

        // If an invalid token address is provided, test will still pass
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
}
