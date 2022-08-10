// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Contract to handle staking and to hold the key on the rewards to be distributed
// One layer of staking rewards distributed to senior time-locked the other to a junior tranche
// Reward balance are updated with every interaction
// Edge case to test for is a situation where there are no further interactions so the maths has to handle how to share between 1 senior and 1 junior token

import "./IERC20.sol";
import "./Steaks.sol";

contract Staking {
    Steaks public stakingToken;
    SteakReceipts public receiptToken;

    address public owner;

    mapping(address => uint256) public balance; // Original staked amount per address
    mapping(address => uint256) public rewards; // Rewards accumulated per address
    mapping(address => uint256) public rewardsPTA; // Rewards per token per address for the previous period
    mapping(address => uint256) public timeStarted; // Starts the clock on the time lock

    uint256 public rewardBalance = 1000; // Hardcoded here but should be eventually pointing at an address for a dynamic reward rate

    uint256 public rewardRate; // Rate per second for accumulating rewards
    uint256 public totalSupply; // Total sum staked
    uint256 public time; // Timestamp for counting the staking periods
    uint256 public rewardPT; // Helper to essentially allocate the rewards in a given time period to a balance
    uint256 public lock; // Time lock to require ahead of withdrawing

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

    modifier updateRewards(address account_) {
        // For each period of time between events, there is an average amount of rewards per token -> See A
        rewardPT = updateRewardsPerToken();
        time = block.timestamp;

        if (account_ != address(0)) {
            rewards[account_] = earned(account_);
            // Having earned as a public view function can provide a hook to query accumulated rewards without drawing gas
            // Update the n-1 rewards per token for a given account in case in one of the future periods an account changes their balance
            rewardsPTA[account_] = rewardPT;
        }

        _;
    }

    // Algorithm
    // Basis from Solidity by Example
    //

    // Please express as per second rate by taking the 31536000th root of an annualized rate
    function setRate(uint256 annualRate_) external onlyOwner {
        rewardRate = annualRate_;
    }

    // Please express the lock duration required in seconds
    function setLock(uint256 lock_) external onlyOwner {
        lock = lock_;
    }

    // Start the clock with stake:
    function stake(uint256 amount_) public updateRewards(msg.sender) {
        // Modifier function updateRewards runs first to cycle through reward calculations
        // Force amount to be greater than 0
        require(amount_ > 0, "Amount must be >0");
        // Transfer tokens for the corresponding receipt
        stakingToken.transferFrom(msg.sender, address(this), amount_);
        receiptToken.transferFrom(address(0), msg.sender, amount_);
        // Update staked amounts
        balance[msg.sender] += amount_;
        totalSupply += amount_;
    }

    function getRewards() public updateRewards(msg.sender) {
        // Require a deposit to have been locked for a minimum duration before drawing out the rewards
        // In practice this means you can add deposits to a balance during a lock
        // They won't extend a lock but they will count against an existing lock
        require(
            block.timestamp - timeStarted[msg.sender] > lock,
            "Deposit lock still valid"
        );
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            stakingToken.transfer(msg.sender, reward);
        }
    }

    function updateRewardsPerToken() public view returns (uint256) {
        // A -> Helper function to update the average amount of rewards per token for a given period
        // The reward per token is essentially the rate in seconds times the duration times the balance staked
        if (totalSupply == 0) {
            return rewardPT;
        }

        // Catching the case when there is no more reward balance left to distribute
        if (
            (rewardRate * totalSupply * (block.timestamp - time) * 1e18) >
            rewardBalance
        ) {
            return
                rewardPT +
                ((rewardRate * totalSupply * (block.timestamp - time) * 1e18) -
                    rewardBalance) /
                totalSupply;
        }

        return
            rewardPT +
            (rewardRate * totalSupply * (block.timestamp - time) * 1e18) /
            totalSupply;
    }

    function earned(address account_) public returns (uint256) {
        // Forcing rewardBalance to never go below 0 - it is used immediately after in updateRewardsPerToken()
        rewardBalance = _max(
            0,
            _min(
                rewardBalance,
                ((balance[account_] *
                    (updateRewardsPerToken() - rewardsPTA[account_])) * 1e18) +
                    rewards[account_]
            )
        );

        return
            ((balance[account_] *
                (updateRewardsPerToken() - rewardsPTA[account_])) * 1e18) +
            rewards[account_];
    }

    function withdraw(uint256 amount_) public updateRewards(msg.sender) {
        require(amount_ > 0, "Amount must be >0");
        require(
            block.timestamp - timeStarted[msg.sender] > lock,
            "Deposit lock still valid"
        );
        amount_ = _min(balance[msg.sender], amount_);
        balance[msg.sender] -= amount_;
        totalSupply -= amount_;
        stakingToken.transfer(msg.sender, amount_);
    }

    // Helper Functions

    // Solidity doesn't have max/min functions
    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }

    function _max(uint256 x, uint256 y) private pure returns (uint256) {
        return x >= y ? x : y;
    }
}
