// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Steaks will replicate the main features of an ERC20 token for the token and the receipt
// Implementing both on the same contract for clarity though I suppose you should probably separate them
// Also imagine that just importing the ERC20 contract spec from OZ is better practice but I am writing this to learn and figure out what all the moving parts are
// So Steaks will have to implement all of the ERC20 token spec all over again

// Heavily inspired by ERC20 but trying to implement it through paraphrasing the key functions this token will need

import "./IERC20.sol";

contract Steaks is IERC20 {
    // Attributes and events

    // Following ERC20 pattern, two events on function calls that document transfers and approvals
    // Adding a third event to document a Staking event
    event Staked(address sender, uint256 value);
    event Unstaked(address recipient, uint256 value);

    // _balances is a key value pair that stores the amount of tokens against each address
    // _allowances is a security function that explicitly asks for approval to change balances on behalf of other addresses
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    // The Steak token will have a fixed token supply. The Steak Receipt token will have a malleable token supply
    uint256 public override totalSupply = 1000;
    uint256 public maxSupply = 2000;
    string public name = "Steak Tokens";
    string public symbol = "STKS";
    uint256 public decimals = 18;

    // Require transfer function to work only if toggle is true

    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {
        require(balanceOf[msg.sender] >= value, "Not enough balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint256 amount) external returns (bool) {
        require(
            totalSupply + amount <= maxSupply,
            "Cannot mint more than total supply of Steaks"
        );

        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
        return true;
    }

    function burn(uint256 amount) external returns (bool) {
        require(
            totalSupply - amount >= 0,
            "Cannot burn more than the total supply"
        );

        balanceOf[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }
}

contract SteakReceipts is IERC20 {
    // Attributes and events

    // Following ERC20 pattern, two events on function calls that document transfers and approvals
    // Adding a third event to document a Staking event
    event Staked(address sender, uint256 value);
    event Unstaked(address recipient, uint256 value);

    // _balances is a key value pair that stores the amount of tokens against each address
    // _allowances is a security function that explicitly asks for approval to change balances on behalf of other addresses
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    // The Steak token will have a fixed token supply. The Steak Receipt token will have a malleable token supply
    uint256 public override totalSupply = 0;

    string public name = "Steak Receipts";
    string public symbol = "stSTKS";
    uint256 public decimals = 18;

    // Require transfer function to work only if toggle is true

    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {
        require(balanceOf[msg.sender] >= value, "Not enough balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint256 amount) external returns (bool) {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
        return true;
    }

    function burn(uint256 amount) external returns (bool) {
        require(
            totalSupply - amount >= 0,
            "Cannot burn more than the total supply"
        );

        balanceOf[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }
}
