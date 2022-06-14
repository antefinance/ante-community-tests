// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Uses the setTokenAddress and setPayerAddress functions to set the addresses
// of the LlamaPay instance(s) and payer address to check
// https://.etherscan.io/address/[CONTRACT_ADDRESS]#readContract to check values
// https://.etherscan.io/address/[CONTRACT_ADDRESS]#writeContract to set values

// NOTE: As of May 2022, a challenger attempting to check this test via web app
// or interacting with the AntePool directly can potentially be front-run. In
// order to avoid being front-run, a potential challenger should deploy an
// instance of the AnteLlamaPayTestChallengerWrapper.sol contract and use that
// to challenge the Ante Pool. Staking functions can be done normally through
// the web app or directly interacting with the AntePool contract.
// https://github.com/antefinance/ante-community-tests/blob/main/contracts/llamapay/

pragma solidity ^0.7.0;

import "../libraries/ante-v05-core/AnteTest.sol";

interface ILlamaPayFactory {
    function getLlamaPayContractByToken(address _token) external view returns (address, bool);
}

interface ILlamaPay {
    function payers(address _payer) external view returns (uint40, uint216);
}

/// @title  LlamaPay never goes backwards in time test
/// @notice Ante Test to check that lastPayerUpdate <= block.timestamp holds
///         for any LlamaPay payer/token. Uses the setter functions provided to
///         set the LlamaPay instance and payer to check.
///         Note: may no longer hold after 231,800 A.D. due to holding timestamp in uint40
contract AnteLlamaPayTest is
    AnteTest("LlamaPay never pays future payments early (lastPayerUpdate[anyone] <= block.timestamp)")
{
    // https://etherscan.io/address/0xde1C04855c2828431ba637675B6929A684f84C7F on Eth Mainnet
    // https://snowtrace.io/address/0x7d507b4c2d7e54da5731f643506996da8525f4a3 on Avax C-Chain
    // https://docs.llamapay.io/technical-stuff/contracts for more chains
    ILlamaPayFactory internal factory;

    address public tokenAddress;
    address public payerAddress;

    constructor(address _llamaPayFactoryAddress) {
        factory = ILlamaPayFactory(_llamaPayFactoryAddress);

        protocolName = "LlamaPay"; // <3
        testedContracts.push(_llamaPayFactoryAddress);
        testedContracts.push(address(0)); // LlamaPay instance once set
    }

    /// @notice Checks that lastPayerUpdate[payer] <= block.timestamp for a
    ///         given payer and LlamaPay instance. Uses the setter functions
    ///         provided to set the token address and payer address to check.
    /// @return true if lastPayerUpdate[payer] <= block.timestamp for the
    ///         LlamaPay instance and payer checked
    function checkTestPasses() external view override returns (bool) {
        // If a valid LlamaPay instance is specified, check it
        (address predictedAddress, bool isDeployed) = factory.getLlamaPayContractByToken(tokenAddress);
        if (isDeployed) {
            (uint40 lastPayerUpdate, ) = ILlamaPay(predictedAddress).payers(payerAddress);

            // We don't need to worry about checking if the payer exists in the
            // payer mapping for this LlamaPay instance since 0 < block.timestamp
            return (lastPayerUpdate <= block.timestamp);
        }

        // If invalid LlamaPay address passed in, test will still pass
        return true;
    }

    /*****************************************************
     * ================ USER INTERFACE ================= *
     *****************************************************/

    /// @notice Sets the payer address for the Ante Test to check
    /// @param  _payerAddress address of payer to check
    function setPayerAddress(address _payerAddress) external {
        // Could check that valid payer mapping exists, but also, an invalid
        // payer address doesn't fail the test so no risk of false positive.
        payerAddress = _payerAddress;
    }

    /// @notice Sets the token address of the LlamaPay instance to check
    /// @param  _tokenAddress address of token to check LlamaPay instance for
    function setTokenAddress(address _tokenAddress) external {
        // Check that LlamaPay instance exists for the token
        (address predictedAddress, bool isDeployed) = factory.getLlamaPayContractByToken(_tokenAddress);
        require(isDeployed, "ANTE: LlamaPay instance not deployed for that token");
        testedContracts[1] = predictedAddress;
        tokenAddress = _tokenAddress;
    }
}
