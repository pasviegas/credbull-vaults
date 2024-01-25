// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { MockToken } from "./mocks/MockToken.sol";
import { SweepableVault } from "../src/sweep/SweepableVault.sol";
import { ImmediateSweepVaultDecorator } from "../src/sweep/ImmediateSweepVaultDecorator.sol";

contract SweepableVaultTest is Test {
    MockToken public token;
    ImmediateSweepVaultDecorator public decorator;
    SweepableVault public vault;

    Account public custodian;
    Account public depositor;

    function setUp() public {
        custodian = makeAccount("custodian");
        depositor = makeAccount("depositor");

        token = new MockToken(1000 ether);
        vault = new SweepableVault(token, "Vault Shares", "sVault");
        decorator = new ImmediateSweepVaultDecorator(vault, custodian.addr);
        vault.transferOwnership(address(decorator));
    }

    function test_deposit_succeeds_and_assets_are_transferred_to_custodian() public {
        vault.enableDecorator(address(decorator));
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);
        decorator.deposit(amount, depositor.addr);
        vm.stopPrank();

        assertEq(token.balanceOf(depositor.addr), 0 ether);
        assertEq(token.balanceOf(address(vault)), 0 ether);
        assertEq(token.balanceOf(custodian.addr), amount);

        assertEq(vault.balanceOf(depositor.addr), amount);
        assertEq(vault.totalAssets(), amount);
    }
}
