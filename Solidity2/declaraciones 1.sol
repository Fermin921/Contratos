// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

contract Token {
    enum UserType {
        TokenHolder,
        Admin,
        Owner
    }
    struct UserInfo {
        address account;
        string firstName;
        string lastName;
        UserType userType;
    }

    mapping(address => uint256) public tokenBalance;
    mapping(address => UserInfo) public registeredUser;
    mapping(address => bool) public frozenAccount;

    address public owner = 0x5113F1e03A11Fb4e25Ad8906CF3B36F79f731095;
    uint256 public constant maxTransferLimit = 15000;

    event Transfer(address from, address to, uint256 value);
    event FrozenAccount(address target, bool frozen);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(uint256 _initialSupply) public {
        owner = msg.sender;
    }
}
