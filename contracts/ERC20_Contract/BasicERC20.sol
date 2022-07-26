pragma solidity >=0.4.22 <0.9.0;

/// @notice This is not a full implementation of ERC20. This contract is to support a unit test.
/// This contract is not a test.
contract BasicERC20 {
    address private owner;
    uint256 private supply = 0;
    mapping(address => uint256) private bank;

    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function mint(uint256 _amount, address to) public {
        supply += _amount;
        bank[to] += _amount;
    }

    function totalSupply() public view returns (uint256) {
        return supply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return bank[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(bank[msg.sender] >= _value);

        bank[msg.sender] -= _value;
        bank[_to] += _value;

        return true;
    }
}
