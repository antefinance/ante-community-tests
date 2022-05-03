//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import {MockLlamaPay} from "./MockLlamaPay.sol";

// Mock LlamaPayFactory contract used only for testing

contract MockLlamaPayFactory {
    bytes32 constant INIT_CODEHASH = keccak256(type(MockLlamaPay).creationCode);

    uint256 public getLlamaPayContractCount;
    address[1000000000] public getLlamaPayContractByIndex;

    function createLlamaPayContract(address _token) external returns (address llamaPayContract) {
        llamaPayContract = address(new MockLlamaPay{salt: bytes32(uint256(uint160(_token)))}());
    }

    /**
      @notice Query the address of the Llama Pay contract for `_token` and whether it is deployed
      @param _token An ERC20 token address
      @return predictedAddress The deterministic address where the llama pay contract will be deployed for `_token`
      @return isDeployed Boolean denoting whether the contract is currently deployed
      */
    function getLlamaPayContractByToken(address _token)
        external
        view
        returns (address predictedAddress, bool isDeployed)
    {
        predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(bytes1(0xff), address(this), bytes32(uint256(uint160(_token))), INIT_CODEHASH)
                    )
                )
            )
        );
        isDeployed = predictedAddress.code.length != 0;
    }
}
