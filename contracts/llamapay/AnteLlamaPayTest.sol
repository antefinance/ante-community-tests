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

// NOTE: As of May 2022, a challenger attempting to check the test can
// potentially be front-run. In order to avoid being front-run,
// deploy an instance of the AnteLlamaPayTestChallengerWrapper.sol contract
// using the wallet you intend to challenge/check test with and use that to challenge
// https://github.com/antefinance/ante-community-tests/blob/main/contracts/llamapay/AnteLlamaPayTestChallengerWrapper.sol
// staking functions can be done normally through the AntePool contract or via web app UI

pragma solidity ^0.7.0;

import "../AnteTest.sol";

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
contract AnteLlamaPayTest is
    AnteTest("LlamaPay never pays future payments early (lastPayerUpdate[anyone] <= block.timestamp)")
{
    // https://etherscan.io/address/0xde1C04855c2828431ba637675B6929A684f84C7F on Eth Mainnet
    ILlamaPayFactory internal factory;

    address public tokenAddress;
    address public payerAddress;

    constructor(address _llamaPayFactoryAddress) {
        factory = ILlamaPayFactory(_llamaPayFactoryAddress);

        protocolName = "LlamaPay"; // <3
        testedContracts.push(_llamaPayFactoryAddress);
        testedContracts.push(address(0)); // test all LlamaPay instances by default
    }

    /// @notice checks that lastPayerUpdate <= block.timestamp for a given
    ///         payer in a given LlamaPay instance
    /// @param llamaPayAddress address of LlamaPay instance to check
    /// @return true if lastPayerUpdate[payer] <= block.timestamp
    function checkSingle(address llamaPayAddress) internal view returns (bool) {
        (uint40 lastPayerUpdate, ) = ILlamaPay(llamaPayAddress).payers(payerAddress);

        // We don't need to worry about checking if the payer exists in the
        // payer mapping for this LlamaPay instance since 0 < block.timestamp
        return (lastPayerUpdate <= block.timestamp);
    }

    /// @notice Checks that lastPayerUpdate[payer] <= block.timestamp for a
    ///         given payer and LlamaPay instance(s). Uses the setter functions
    ///         provided to set the token address(es) and payer address to
    ///         check. If 0x0 is passed as token address, will check through
    ///         all LlamaPay contracts in factory; otherwise, will check for
    ///         the single LlamaPay instance provided.
    /// @return true if lastPayerUpdate[payer] <= block.timestamp for all
    ///         LlamaPay contracts checked
    function checkTestPasses() external view override returns (bool) {
        // If a valid LlamaPay instance is specified, check it
        (address predictedAddress, bool isDeployed) = factory.getLlamaPayContractByToken(tokenAddress);
        if (isDeployed) {
            return checkSingle(predictedAddress);
        }

        // If token address is 0x0, loop through all LlamaPay instances
        // TODO implement max # to check to prevent block stuffing attack?
        for (uint256 i = 0; i < factory.getLlamaPayContractCount(); i++) {
            // If any LlamaPay instance fails, fail the entire test
            if (!checkSingle(factory.getLlamaPayContractByIndex(i))) {
                return false;
            }
        }

        // If we end up here somehow (invalid inputs), test will still pass
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
    /// @param  _tokenAddress address of token to check LlamaPay instance for.
    ///         If 0x0 is set, the Ante Test will check all LlamaPay instances
    function setTokenAddress(address _tokenAddress) external {
        // Check that LlamaPay instance exists for the token but also allow 0x0
        (address predictedAddress, bool isDeployed) = factory.getLlamaPayContractByToken(_tokenAddress);
        require(isDeployed || _tokenAddress == address(0), "ANTE: LlamaPay instance not deployed");
        testedContracts[1] = predictedAddress;
        tokenAddress = _tokenAddress;
    }
}
