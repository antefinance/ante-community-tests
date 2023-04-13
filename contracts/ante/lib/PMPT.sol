/// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import {RLPReader} from './RLPReader.sol';

library PMPT {
  using RLPReader for RLPReader.RLPItem;
  using RLPReader for bytes;
  function verifyProof(bytes32 root, bytes memory key, bytes[] memory proof) internal view returns(bool) {
    for(uint proofIndex = 0; proofIndex < proof.length; proofIndex++ ){
      RLPReader.RLPItem[] memory item = proof[proofIndex].toRlpItem().toList();
      bytes memory itemKey = item[0].toBytes();
      bytes memory itemValue = item[1].toBytes();
      bytes32 itemKeyHashed = keccak256(itemKey);

    }

    



  }
}