// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { MockToken } from "./mocks/MockToken.sol";
import { SweepableVault } from "../src/sweep/SweepableVault.sol";
import { ImmediateSweepVaultDecorator } from "../src/sweep/ImmediateSweepVaultDecorator.sol";
import { FixedYieldOnMaturityVaultDecorator } from "../src/yield/FixedYieldOnMaturityVaultDecorator.sol";
import { FixedYieldOnMaturityVaultStrategy } from "../src/yield/FixedYieldOnMaturityVaultStrategy.sol";

contract FixedYieldVaultDecoratorTest is Test {
    MockToken public token;
    ImmediateSweepVaultDecorator public immediateSweepDecorator;
    FixedYieldOnMaturityVaultDecorator public decorator;
    FixedYieldOnMaturityVaultStrategy public strategy;
    SweepableVault public vault;

    Account public custodian;
    Account public depositor;

    function setUp() public {
        custodian = makeAccount("custodian");
        depositor = makeAccount("depositor");

        token = new MockToken(1000 ether);
        vault = new SweepableVault(token, "Vault Shares", "sVault");

        immediateSweepDecorator = new ImmediateSweepVaultDecorator(vault, custodian.addr);
        vault.enableDecorator(address(immediateSweepDecorator));

        decorator = new FixedYieldOnMaturityVaultDecorator(immediateSweepDecorator, 10);
        immediateSweepDecorator.enableDecorator(address(decorator));

        strategy = new FixedYieldOnMaturityVaultStrategy(decorator);
        decorator.enableDecorator(address(strategy));
    }

    function test_redeem_succeeds_and_the_depositor_receives_their_yield() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);
        strategy.deposit(amount, depositor.addr);
        vm.stopPrank();

        token.mint(custodian.addr, 10 ether + 1);

        vm.startPrank(custodian.addr);
        token.approve(custodian.addr, 110 ether + 1);
        token.transferFrom(custodian.addr, address(vault), 110 ether + 1);
        vm.stopPrank();

        strategy.mature();

        vm.prank(depositor.addr);
        strategy.redeem(strategy.balanceOf(depositor.addr), depositor.addr, depositor.addr);

        assertEq(token.balanceOf(depositor.addr), 110 ether);
        assertEq(token.balanceOf(address(vault)), 1);
        assertEq(token.balanceOf(custodian.addr), 0);
    }

    function test_mature_fails_if_there_is_not_enough_funds_to_mature() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);
        strategy.deposit(amount, depositor.addr);
        vm.stopPrank();

        vm.expectRevert(FixedYieldOnMaturityVaultDecorator.NotEnoughBalanceToMature.selector);
        strategy.mature();
    }

    function test_redeem_fails_before_maturity() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);
        strategy.deposit(amount, depositor.addr);
        vm.expectRevert(FixedYieldOnMaturityVaultDecorator.VaultNotMatured.selector);
        strategy.redeem(100 ether, depositor.addr, depositor.addr);
        vm.stopPrank();
    }
}
