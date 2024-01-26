// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { MockToken } from "./mocks/MockToken.sol";
import { MockVaultDecorator } from "./mocks/MockVaultDecorator.sol";
import { MockVaultStrategy } from "./mocks/MockVaultStrategy.sol";
import { DecorableVault } from "../src/DecorableVault.sol";

contract AVaultDecoratorTest is Test {
    MockToken public token;
    MockVaultDecorator public decorator;
    MockVaultStrategy public strategy;
    DecorableVault public vault;

    Account public depositor;

    function setUp() public {
        depositor = makeAccount("depositor");

        token = new MockToken(1000 ether);
        vault = new DecorableVault(token, "Vault Shares", "sVault");
        decorator = new MockVaultDecorator(vault);
        strategy = new MockVaultStrategy(decorator);
    }

    function test_deposit_should_fail_if_decorator_is_disabled() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);

        vm.expectRevert(DecorableVault.DecoratorIsNotCaller.selector);
        strategy.deposit(amount, depositor.addr);
        vm.stopPrank();
    }

    function test_deposit_executes_in_underlying_vault() public {
        vault.enableDecorator(address(decorator));
        decorator.enableDecorator(address(strategy));

        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);
        strategy.deposit(amount, depositor.addr);
        vm.stopPrank();

        assertEq(token.balanceOf(depositor.addr), 0 ether);
        assertEq(strategy.balanceOf(depositor.addr), amount);
    }
}
