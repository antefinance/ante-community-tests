/// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./RLPReader.sol";
import "hardhat/console.sol";
/*
    Documentation:
    - https://eth.wiki/en/fundamentals/patricia-tree
    - https://github.com/blockchainsllc/in3/wiki/Ethereum-Verification-and-MerkleProof
    - https://easythereentropy.wordpress.com/2014/06/04/understanding-the-ethereum-trie/
*/
library MPT {
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for RLPReader.Iterator;

    struct MerkleProof {
        bytes32 expectedRoot;
        bytes key;
        bytes[] proof;
        uint256 keyIndex;
        uint256 proofIndex;
        bytes expectedValue;
    }

    function verifyTrieProof(
        MerkleProof memory data
    ) view internal returns (uint256)
    {
      console.log("verifyTrieProof");

      bytes memory node = data.proof[data.proofIndex];
      console.log("node length", node.length);
      console.log("VTP 1");
      RLPReader.Iterator memory dec = RLPReader.toRlpItem(node).iterator();
      console.log("VTP 2");
      if (data.keyIndex == 0) {
        console.log("VTP 3");
        if(keccak256(node) != data.expectedRoot){
          console.log("VTP 4");
          return 0;
        }
      } else if (node.length < 32) {
        console.log("VTP 5");
          bytes32 root = bytes32(dec.next().toUint());
          console.log("VTP 6");
          if(root != data.expectedRoot) {
            console.log("VTP 7");
              return 2;
          }
      } else {
        console.log("VTP 8");
          if(keccak256(node) != data.expectedRoot){
            console.log("VTP 9");
              return 3;
          }
      }
      
      console.log("VTP 10");
      uint256 numberItems = RLPReader.numItems(dec.item);
      console.log("VTP 11");
      // branch
      if (numberItems == 17) {
        console.log("VTP 12");
          return verifyTrieProofBranch(data);
      }
      // leaf / extension
      else if (numberItems == 2) {
        console.log("VTP 13");
          return verifyTrieProofLeafOrExtension(dec, data);
      }
      console.log("VTP 14");
      if (data.expectedValue.length == 0) return 0;
      else return 1001;
    }

    function verifyTrieProofBranch(
        MerkleProof memory data
    ) view internal returns (uint256)
    {
      console.log("VTP 15",data.proofIndex);
        bytes memory node = data.proof[data.proofIndex];
        console.log("VTP 16", data.keyIndex, data.key.length);
        if (data.keyIndex >= data.key.length) {
          console.log("VTP 17");
            bytes memory item = RLPReader.toRlpItem(node).toList()[16].toBytes();
            console.log("VTP 18");
            if (keccak256(item) == keccak256(data.expectedValue)) {
              console.log("VTP 19");
                return 0;
            }
        }
        else {
          console.log("VTP 20", data.key.length, data.keyIndex);
            uint256 index = uint256(uint8(data.key[data.keyIndex]));
            console.log("VTP 21", index, data.keyIndex, data.proofIndex);
            RLPReader.RLPItem[] memory items = RLPReader.toRlpItem(node).toList();
            console.log("VTP 21.5", items.length, index);
            if(items.length <= index) return 8888;
            bytes memory _newExpectedRoot = items[index].toBytes();
            console.log("VTP 22");
            if (!(_newExpectedRoot.length == 0)) {
              console.log("VTP 23");
                data.expectedRoot = b2b32(_newExpectedRoot);
                data.keyIndex += 1;
                data.proofIndex += 1;
                return verifyTrieProof(data);
            }
        }

        if (data.expectedValue.length == 0) return 0;
        else return 1000;
    }

    function verifyTrieProofLeafOrExtension(
      RLPReader.Iterator memory dec,
        MerkleProof memory data
    ) view internal returns (uint256)
    {
        bytes memory nodekey = dec.next().toBytes();
        bytes memory nodevalue = dec.next().toBytes();
        uint256 prefix;
        assembly {
            let first := shr(248, mload(add(nodekey, 32)))
            prefix := shr(4, first)
        }

        if (prefix == 2) {
            // leaf even
            uint256 length = nodekey.length - 1;
            bytes memory actualKey = sliceTransform(nodekey, 1, length, false);
            bytes memory restKey = sliceTransform(data.key, data.keyIndex, length, false);
            if (keccak256(data.expectedValue) == keccak256(nodevalue)) {
                if (keccak256(actualKey) == keccak256(restKey)) return 0;
                if (keccak256(expandKeyEven(actualKey)) == keccak256(restKey)) return 0;
            }
        }
        else if (prefix == 3) {
            // leaf odd
            bytes memory actualKey = sliceTransform(nodekey, 0, nodekey.length, true);
            bytes memory restKey = sliceTransform(data.key, data.keyIndex, data.key.length - data.keyIndex, false);
            if (keccak256(data.expectedValue) == keccak256(nodevalue)) {
                if (keccak256(actualKey) == keccak256(restKey)) return 0;
                if (keccak256(expandKeyOdd(actualKey)) == keccak256(restKey)) return 0;
            }
        }
        else if (prefix == 0) {
            // extension even
            uint256 extensionLength = nodekey.length - 1;
            bytes memory shared_nibbles = sliceTransform(nodekey, 1, extensionLength, false);
            bytes memory restKey = sliceTransform(data.key, data.keyIndex, extensionLength, false);
            if (
                keccak256(shared_nibbles) == keccak256(restKey) ||
                keccak256(expandKeyEven(shared_nibbles)) == keccak256(restKey)

            ) {
                data.expectedRoot = b2b32(nodevalue);
                data.keyIndex += extensionLength;
                data.proofIndex += 1;
                return verifyTrieProof(data);
            }
        }
        else if (prefix == 1) {
            // extension odd
            uint256 extensionLength = nodekey.length;
            bytes memory shared_nibbles = sliceTransform(nodekey, 0, extensionLength, true);
            bytes memory restKey = sliceTransform(data.key, data.keyIndex, extensionLength, false);
            if (
                keccak256(shared_nibbles) == keccak256(restKey) ||
                keccak256(expandKeyEven(shared_nibbles)) == keccak256(restKey)
            ) {
                data.expectedRoot = b2b32(nodevalue);
                data.keyIndex += extensionLength;
                data.proofIndex += 1;
                return verifyTrieProof(data);
            }
        }
        else {
            //revert("Invalid proof");
            return 9999;
        }
        if (data.expectedValue.length == 0) return 0;
        else return 1111;
    }

    function b2b32(bytes memory data) view internal returns(bytes32 part) {
        assembly {
            part := mload(add(data, 32))
        }
    }

    function sliceTransform(
        bytes memory data,
        uint256 start,
        uint256 length,
        bool removeFirstNibble
    )
        view internal returns(bytes memory)
    {
        uint256 slots = length / 32;
        uint256 rest = 256 - (length % 32) * 8;
        uint256 pos = 32;
        uint256 si = 0;
        uint256 source;
        bytes memory newdata = new bytes(length);
        assembly {
            source := add(start, data)

            if removeFirstNibble {
                mstore(
                    add(newdata, pos),
                    shr(4, shl(4, mload(add(source, pos))))
                )
                si := 1
                pos := add(pos, 32)
            }

            for {let i := si} lt(i, slots) {i := add(i, 1)} {
                mstore(add(newdata, pos), mload(add(source, pos)))
                pos := add(pos, 32)
            }
            mstore(add(newdata, pos), shl(
                rest,
                shr(rest, mload(add(source, pos)))
            ))
        }
    }

    function getNibbles(bytes1 b) internal view returns (bytes1 nibble1, bytes1 nibble2) {
        assembly {
                nibble1 := shr(4, b)
                nibble2 := shr(4, shl(4, b))
            }
    }

    function expandKeyEven(bytes memory data) internal view returns (bytes memory) {
        uint256 length = data.length * 2;
        bytes memory expanded = new bytes(length);

        for (uint256 i = 0 ; i < data.length; i++) {
            (bytes1 nibble1, bytes1 nibble2) = getNibbles(data[i]);
            expanded[i * 2] = nibble1;
            expanded[i * 2 + 1] = nibble2;
        }
        return expanded;
    }

    function expandKeyOdd(bytes memory data) internal view returns(bytes memory) {
        uint256 length = data.length * 2 - 1;
        bytes memory expanded = new bytes(length);
        expanded[0] = data[0];

        for (uint256 i = 1 ; i < data.length; i++) {
            (bytes1 nibble1, bytes1 nibble2) = getNibbles(data[i]);
            expanded[i * 2 - 1] = nibble1;
            expanded[i * 2] = nibble2;
        }
        return expanded;
    }
}

