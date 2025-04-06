// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {LendingPool} from "../src/LendingPool.sol";

contract DeployLendingPool is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        LendingPool lendingPool = new LendingPool();
        console.log("LendingPool deployed at:", address(lendingPool));

        vm.stopBroadcast();
    }
}