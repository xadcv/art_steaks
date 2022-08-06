// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Contract to handle staking and to hold the key on the rewards to be distributed
// One layer of staking rewards distributed to senior time-locked the other to a junior tranche
// Reward balances are updated with every interaction
// Edge case to test for is a situation where there are no further interactions so the maths has to handle how to share between 1 senior and 1 junior token