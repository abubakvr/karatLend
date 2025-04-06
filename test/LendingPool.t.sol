// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "../src/LendingPool.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// Mock ERC20 token for testing
contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract LendingPoolTest is Test {
    LendingPool public lendingPool;
    MockToken public token;

    address public owner;
    address public alice;
    address public bob;

    uint256 public constant INITIAL_BALANCE = 1000 * 10 ** 18; // 1000 tokens

    function setUp() public {
        // Deploy contracts
        lendingPool = new LendingPool();
        token = new MockToken();

        // Set up test addresses
        owner = address(this);
        alice = address(0x1);
        bob = address(0x2);

        // Fund test addresses
        token.transfer(alice, INITIAL_BALANCE);
        token.transfer(bob, INITIAL_BALANCE);

        // Label addresses for better trace output
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(token), "Mock Token");
        vm.label(address(lendingPool), "Lending Pool");
    }

    function testInitialState() public view {
        assertEq(lendingPool.owner(), address(this));
        assertEq(lendingPool.getUserTokenCount(alice), 0);
        assertEq(lendingPool.userSupplied(alice, address(token)), 0);
    }

    function testDeposit() public {
        uint256 depositAmount = 100 * 10 ** 18;

        // Switch to Alice's context
        vm.startPrank(alice);

        // Approve tokens
        token.approve(address(lendingPool), depositAmount);

        // Deposit tokens
        lendingPool.deposit(address(token), depositAmount);

        vm.stopPrank();

        // Verify deposit
        assertEq(lendingPool.userSupplied(alice, address(token)), depositAmount);
        assertEq(lendingPool.getUserTokenCount(alice), 1);
        assertEq(lendingPool.getUserTokenByIndex(alice, 0), address(token));
    }

    function testMultipleDeposits() public {
        uint256 firstDeposit = 100 * 10 ** 18;
        uint256 secondDeposit = 50 * 10 ** 18;

        vm.startPrank(alice);

        // First deposit
        token.approve(address(lendingPool), firstDeposit);
        lendingPool.deposit(address(token), firstDeposit);

        // Second deposit
        token.approve(address(lendingPool), secondDeposit);
        lendingPool.deposit(address(token), secondDeposit);

        vm.stopPrank();

        // Verify total deposit
        assertEq(lendingPool.userSupplied(alice, address(token)), firstDeposit + secondDeposit);
        assertEq(lendingPool.getUserTokenCount(alice), 1); // Still 1 unique token
    }

    function testWithdraw() public {
        uint256 depositAmount = 100 * 10 ** 18;
        uint256 withdrawAmount = 60 * 10 ** 18;

        // Deposit first
        vm.startPrank(alice);
        token.approve(address(lendingPool), depositAmount);
        lendingPool.deposit(address(token), depositAmount);

        // Record balance before withdrawal
        uint256 balanceBefore = token.balanceOf(alice);

        // Withdraw
        lendingPool.withdraw(address(token), withdrawAmount);
        vm.stopPrank();

        // Verify withdrawal
        assertEq(lendingPool.userSupplied(alice, address(token)), depositAmount - withdrawAmount);
        assertEq(token.balanceOf(alice), balanceBefore + withdrawAmount);
    }

    function test_RevertWhen_WithdrawingTooMuch() public {
        uint256 depositAmount = 100 * 10 ** 18;
        uint256 withdrawAmount = 200 * 10 ** 18;

        vm.startPrank(alice);

        // Deposit
        token.approve(address(lendingPool), depositAmount);
        lendingPool.deposit(address(token), depositAmount);

        // Try to withdraw more than deposited (should fail)
        vm.expectRevert("Insufficient balance");
        lendingPool.withdraw(address(token), withdrawAmount);

        vm.stopPrank();
    }

    function test_RevertWhen_DepositingZeroAmount() public {
        vm.startPrank(alice);
        token.approve(address(lendingPool), 0);

        vm.expectRevert("Amount must be greater than 0");
        lendingPool.deposit(address(token), 0);
        vm.stopPrank();
    }

    function test_RevertWhen_DepositingInvalidToken() public {
        vm.startPrank(alice);
        vm.expectRevert("Invalid token");
        lendingPool.deposit(address(0), 100 * 10 ** 18);
        vm.stopPrank();
    }

    function testMultipleUsers() public {
        uint256 aliceDeposit = 100 * 10 ** 18;
        uint256 bobDeposit = 150 * 10 ** 18;

        // Alice deposits
        vm.startPrank(alice);
        token.approve(address(lendingPool), aliceDeposit);
        lendingPool.deposit(address(token), aliceDeposit);
        vm.stopPrank();

        // Bob deposits
        vm.startPrank(bob);
        token.approve(address(lendingPool), bobDeposit);
        lendingPool.deposit(address(token), bobDeposit);
        vm.stopPrank();

        // Verify both users' deposits
        assertEq(lendingPool.userSupplied(alice, address(token)), aliceDeposit);
        assertEq(lendingPool.userSupplied(bob, address(token)), bobDeposit);
        assertEq(lendingPool.getUserTokenCount(alice), 1);
        assertEq(lendingPool.getUserTokenCount(bob), 1);
    }

    // Test events
    function testDepositEvent() public {
        uint256 depositAmount = 100 * 10 ** 18;

        vm.startPrank(alice);
        token.approve(address(lendingPool), depositAmount);

        vm.expectEmit(true, false, false, true);
        emit LendingPool.Deposited(alice, address(token), depositAmount);
        lendingPool.deposit(address(token), depositAmount);
        vm.stopPrank();
    }

    function testWithdrawEvent() public {
        uint256 depositAmount = 100 * 10 ** 18;
        uint256 withdrawAmount = 60 * 10 ** 18;

        vm.startPrank(alice);
        token.approve(address(lendingPool), depositAmount);
        lendingPool.deposit(address(token), depositAmount);

        vm.expectEmit(true, false, false, true);
        emit LendingPool.Withdrawn(alice, address(token), withdrawAmount);
        lendingPool.withdraw(address(token), withdrawAmount);
        vm.stopPrank();
    }
}
