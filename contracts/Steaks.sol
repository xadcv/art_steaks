// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Contract to handle staking and to hold the key on the rewards to be distributed
// One layer of staking rewards distributed to senior time-locked the other to a junior tranche
// Reward balances are updated with every interaction
// Edge case to test for is a situation where there are no further interactions so the maths has to handle how to share between 1 senior and 1 junior token

import "./IERC20.sol";
import "./Steaks.sol";

contract Staking {
    Steaks public stakingToken;
    SteakReceipts public receiptToken;

    address public owner;

    mapping(address => uint256) public balance; // Original staked amount per address
    mapping(address => uint256) public rewards; // Rewards accumulated per address

    uint256 public maxRewards = 1000; // Hardcoded here but should be eventually pointing at an address for a dynamic reward rate
    uint256 public rewardRate; // Rate per second for accumulating rewards
    uint256 public rewardSum; // Sum of rewardRate * dt * 1e18 / totalSupply - formula from solidity by example
    uint256 public totalSupply;

    // The contract is deployed by an owner who gates the most important function
    constructor(address _stakingToken, address _receiptToken) {
        owner = msg.sender;
        stakingToken = Steaks(_stakingToken);
        receiptToken = SteakReceipts(_receiptToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner address can set");
        _;
    }

    function stake(uint256 amount_) public {
        // To include an update rewards modifier
        require(amount_ > 0, "Amount must be >0");
        stakingToken.transferFrom(msg.sender, address(this), amount_);
        receiptToken.transferFrom(address(0), msg.sender, amount_);
        balance[msg.sender] += amount_;
        totalSupply += amount_;
    }

    function getRewards() public {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            stakingToken.transferFrom(address(0), msg.sender, amount_);
        }
    }

    function withdraw(uint256 amount_) public {
        require(amount_ > 0, "Amount must be >0");
        getRewards();
        balances[msg.sender] -= amount_;
        totalSupply -= amount;
        stakingToken.transfer(msg.sender, amount_);
    }

    // Helper Functions

    // Solidity doesn't have max/min functions
    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }

    // Calculate the time rewards were last calculated
}
