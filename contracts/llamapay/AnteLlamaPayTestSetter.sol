// SPDX-License-Identifier: GPL-3.0-only

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;

import {LlamaPayFactory} from "./interfaces/LlamaPayFactory.sol";
import {LlamaPay} from "./interfaces/LlamaPay.sol";

/// @title  ...
/// @notice contract to be able to set the ID of the llamapay instance to check and the payer address
contract AnteLlamaPayTestSetter {
    // https://etherscan.io/address/
    address public constant LLAMAPAY_FACTORY_ADDRESS = 0x0000000000000000000000000000000000000000;

    address public tokenAddress;
    address public payerAddress;

    /// @notice Checks asdf
    function setPayerAddress(address _payerAddress) external {
        //check that payer address is valid? is there a way to do this without getting expensive?
        require(_payerAddress != 0x0000000000000000000000000000000000000000, "Invalid payer address");
        // TODO would be more thorough to loop through llamapay contracts and verify that at least one
        // instance of a valid payer mapping exists

        payerAddress = _payerAddress;
    }

    /// @notice Checks asdff
    function setTokenAddress(address _tokenAddress) external {
        //check that token address exists in llamapayfactory list but allow 0x0
        if (_tokenAddress != 0x0000000000000000000000000000000000000000) {
            require(
                LlamaPayFactory(LLAMAPAY_FACTORY_ADDRESS).payContracts(_tokenAddress) !=
                    0x0000000000000000000000000000000000000000,
                "LlamaPay contract for given token does not exist"
            );
        }

        tokenAddress = _tokenAddress;
    }

    // tokenAddress of 0x0 means check payer against all tokens
    function getLlamaPayTestArgs() external view returns (address _payerAddress, address _tokenAddress) {
        return (payerAddress, tokenAddress);
    }
}
