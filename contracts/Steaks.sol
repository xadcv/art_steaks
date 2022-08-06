// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Steaks will replicate the main features of an ERC20 token for the token and the receipt
// Implementing both on the same contract for clarity though I suppose you should probably separate them
// Also imagine that just importing the ERC20 contract spec from OZ is better practice but I am writing this to learn and figure out what all the moving parts are
// So Steaks will have to implement all of the ERC20 token spec all over again

// Heavily inspired by ERC20 but trying to implement it through paraphrasing the key functions this token will need

contract ERC20 {
    // Attributes and events
    event Transfer(address from, address to, uint256 value);
    event Approval(address owner, address spender, uint256 value);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    // In order for the token to move will require this bool to be False
    bool private _transferrable;

    // Functions

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
}

contract Steaks {

}

// Change
