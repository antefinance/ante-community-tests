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
import {AnteLlamaPayTestSetter} from "./AnteLlamaPayTestSetter.sol";

/// @title  ...
/// @notice Ante Test to check ...
/// may no longer hold after 231,800 A.D.
contract AnteLlamaPayTest is AnteTest("Ante LlamaPay Test") {
    // https://etherscan.io/address/
    address public constant LLAMAPAY_FACTORY_ADDRESS = 0x0000000000000000000000000000000000000000;
    LlamaPayFactory internal factory;

    // https://etherscan.io/address/
    address public constant LLAMAPAY_ANTE_TEST_SETTER_ADDRESS = 0x0000000000000000000000000000000000000000;

    constructor() {
        factory = LlamaPayFactory(LLAMAPAY_FACTORY_ADDRESS);

        protocolName = "LlamaPay"; // <3
        testedContracts = [LLAMAPAY_FACTORY_ADDRESS];
    }

    /// @notice checks that lastPayerUpdate <= block.timestamp for a given payer in a given LlamaPay instance
    /// @param payerAddress address of payer to check
    /// @param payContractAddress address of specific LlamaPay instance to check
    /// @return true if lastPayerUpdate[payer] <= block.timestamp
    function checkSingle(address payerAddress, address payContractAddress) public view returns (bool) {
        (uint40 lastPayerUpdate, ) = LlamaPay(payContractAddress).payers(payerAddress);

        // even if payer is not in the payer list for this LlamaPay instance, will return true (lastPayerUpdate = 0)
        return (lastPayerUpdate <= block.timestamp);
    }

    /// @notice Checks that lastPayerUpdate[payer] <= block.timestamp for a given payer and LlamaPay contract(s)
    ///         Uses the AnteLlamaPayTestSetter to set the token addresses and payer address to check
    ///         if 0x0 is passed as token address, will check through all LlamaPay contracts in factory
    ///         otherwise, will check for a the single LlamaPay instance provided
    /// @return true if lastPayerUpdate[payer] <= block.timestamp for all LlamaPay contracts checked
    function checkTestPasses() external view override returns (bool) {
        // check AnteLlamaPayTestSetter contract for token address(es) and payer address to check
        (address payerAddress, address tokenAddress) = AnteLlamaPayTestSetter(LLAMAPAY_ANTE_TEST_SETTER_ADDRESS)
            .getLlamaPayTestArgs();

        // if a valid token is specified, check payer for specific token llamapay contract
        if (tokenAddress != 0x0000000000000000000000000000000000000000) {
            // TestSetter already checks tokenAddress in payContracts
            return checkSingle(payerAddress, factory.payContracts(tokenAddress));
        }

        // otherwise, if token address is 0x0, loop all tokens in llamapay factory
        for (uint256 i = 0; i < factory.payContractsArrayLength(); i++) {
            // if any llamapay instance fails, fail the test
            if (checkSingle(payerAddress, factory.payContractsArray(i)) == false) {
                return false;
            }
        }

        return true;
    }
}
