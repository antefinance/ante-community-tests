// =================== CS251 DEX Project =================== // 
//        @authors: Simon Tao '22, Mathew Hogan '22          //
// ========================================================= //    
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Please check out the OpenZeppelin contracts for ERC20 tokens!
// Links can be found in the the respective solidity files
import './erc20.sol';

contract WETH is ERC20 {
    address private owner;
    string public constant symbol_ = 'WETH';                 
    string public constant name_ = 'Wrapped ETH';

    constructor() ERC20(name_, symbol_) {
        owner = msg.sender;
    }

    function setOwner(address _owner) public {
        require(msg.sender == owner, "Not the owner");
        owner = _owner;
    }

    /**
     * Creates `amount` tokens, increasing the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address (the "Black Hole").
     *
     * Requirements:
     *  - only the owner of this contract can mint new tokens
     *  - the account who recieves the minted tokens cannot be the zero address
     *  - you can change the inputs or the scope of your function, as needed
     */
    function mint(address recipient, uint amount) public {
        require(msg.sender == owner, "Not authorized to mint");
        _mint(recipient, amount);
    }
}