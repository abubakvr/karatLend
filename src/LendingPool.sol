// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LendingPool {
    address public owner;

    /// @notice user => token => amount deposited
    mapping(address => mapping(address => uint256)) public userSupplied;

    /// @notice Track which tokens user has deposited at least once
    mapping(address => address[]) public userTokensSupplied;

    mapping(address => mapping(address => bool)) public hasDepositedToken;

    // Total supply & borrow per user per token
    mapping(address => mapping(address => uint256)) public userBorrowed;

    // Events
    event Deposited(address indexed owner, address token, uint256 amount);
    event Withdrawn(address indexed owner, address token, uint256 amount);

    /**
     * @notice Constructor to set the owner of the contract
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Deposit ERC20 tokens into the lending pool
     * @param token Address of the ERC20 token to deposit
     * @param amount Amount of tokens to deposit
     */
    function deposit(address token, uint256 amount) external {
        require(token != address(0), "Invalid token");
        require(amount > 0, "Amount must be greater than 0");

        // Transfer the tokens from user to this contract
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        // Update the user's supply balance
        userSupplied[msg.sender][token] += amount;

        // Track token if this is the user's first time depositing it
        if (!hasDepositedToken[msg.sender][token]) {
            userTokensSupplied[msg.sender].push(token);
            hasDepositedToken[msg.sender][token] = true;
        }

        emit Deposited(msg.sender, token, amount);
    }

    /**
     * @notice Withdraw ERC20 tokens from the lending pool
     * @param token Address of the ERC20 token to withdraw
     * @param amount Amount of tokens to withdraw
     */
    function withdraw(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(token != address(0), "Invalid token address");
        require(userSupplied[msg.sender][token] >= amount, "Insufficient balance");

        // Update the user's balance before transfer
        userSupplied[msg.sender][token] -= amount;

        // Transfer tokens back to the user
        IERC20(token).transfer(msg.sender, amount);

        emit Withdrawn(msg.sender, token, amount);
    }

      /**
     * @notice Get number of unique tokens a user has supplied
     * @param user Address of the user
     * @return uint256 Number of unique tokens supplied by the user
     */
    function getUserTokenCount(address user) external view returns (uint256) {
        return userTokensSupplied[user].length;
    }

    /**
     * @notice Get a token address by index for a user
     * @param user Address of the user
     * @param index Index of the token in the user's supplied tokens array
     * @return address Address of the token at the given index
     */
    function getUserTokenByIndex(address user, uint256 index) external view returns (address) {
        return userTokensSupplied[user][index];
    }

    /**
     * @notice Get the balance of a specific token for a user
     * @param user Address of the user
     * @param token Address of the token
     * @return uint256 The balance of the token for the user
     */
    function getUserBalance(address user, address token) external view returns (uint256) {
        require(user != address(0), "User address is required");
        require(token != address(0), "User address is required");
        return userSupplied[user][token];
    }

    /**
     * @notice Get the total balance of a specific token in the lending pool
     * @param token Address of the token
     * @return uint256 The total balance of the token in the lending pool
     */
    function getTokenBalance(address token) external view returns (uint256) {
        require(token != address(0), "Token address is required");
        return IERC20(token).balanceOf(address(this));
    }
}
