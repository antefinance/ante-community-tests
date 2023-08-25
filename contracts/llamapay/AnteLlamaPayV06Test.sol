// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;

import "../libraries/ante-v06-core/AnteTest.sol";

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
contract AnteLlamaPayV06Test is
    AnteTest("LlamaPay never pays future payments early (lastPayerUpdate[anyone] <= block.timestamp) (V06)")
{
    // Eth Mainnet: https://etherscan.io/address/0xde1C04855c2828431ba637675B6929A684f84C7F
    // Polygon: https://polygonscan.com/address/0xde1C04855c2828431ba637675B6929A684f84C7F
    // BSC: https://bscscan.com/address/0xde1C04855c2828431ba637675B6929A684f84C7F
    // Fantom: https://ftmscan.com/address/0xde1C04855c2828431ba637675B6929A684f84C7F
    // Arbitrum: https://arbiscan.io/address/0xde1C04855c2828431ba637675B6929A684f84C7F
    // Optimism: https://optimistic.etherscan.io/address/0xde1C04855c2828431ba637675B6929A684f84C7F
    // Gnosis/xDai: https://gnosisscan.io/address/0xde1C04855c2828431ba637675B6929A684f84C7F
    // Avax C-Chain: https://snowtrace.io/address/0x7D507B4C2d7e54dA5731F643506996Da8525f4A3
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

    function getStateTypes() external pure override returns (string memory) {
        return "address,address";
    }

    function getStateNames() external pure override returns (string memory) {
        return "tokenAddress,payerAddress";
    }

    /// @notice Checks that lastPayerUpdate[payer] <= block.timestamp for a
    ///         given payer and LlamaPay instance. Uses the setter functions
    ///         provided to set the token address and payer address to check.
    /// @return true if lastPayerUpdate[payer] <= block.timestamp for the
    ///         LlamaPay instance and payer checked
    function checkTestPasses() public view override returns (bool) {
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

    function _setState(bytes memory _state) internal override {
        // Could check that valid payer mapping exists, but also, an invalid
        // payer address doesn't fail the test so no risk of false positive.
        (address _tokenAddress, address _payerAddress) = abi.decode(_state, (address, address));

        // Check that LlamaPay instance exists for the token
        (address predictedAddress, bool isDeployed) = factory.getLlamaPayContractByToken(_tokenAddress);
        require(isDeployed, "ANTE: LlamaPay instance not deployed for that token");
        testedContracts[1] = predictedAddress;
        tokenAddress = _tokenAddress;
        payerAddress = _payerAddress;
    }
}
