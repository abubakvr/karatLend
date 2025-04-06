// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {IERC20} from "./IERC20.sol";

contract LendingPool {
    address public owner;
    // Total supply & borrow per user per token
    mapping(address => mapping(address => uint256)) public userSupplied; // user => token => amount
    mapping(address => mapping(address => uint256)) public userBorrowed; // user => token => amount

    // Event for token removal
    event Deposited(address indexed owner, address token, uint256 amount);

    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(token != address(0), "Invalid token address");

        // Transfer tokens from user to the lending pool
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Update the user's balance for this token
        userSupplied[msg.sender][token] += amount;

        emit Deposited(msg.sender, token, amount);
    }
}
