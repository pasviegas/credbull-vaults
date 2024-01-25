// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { MockToken } from "./mocks/MockToken.sol";
import { ConcreteVault } from "./mocks/ConcreteVault.sol";
import { DecorableVault } from "../src/DecorableVault.sol";

contract AVaultDecoratorTest is Test {
    MockToken public token;
    ConcreteVault public decorator;
    DecorableVault public vault;

    Account public depositor;

    function setUp() public {
        depositor = makeAccount("depositor");

        token = new MockToken(1000 ether);
        vault = new DecorableVault(token, "Vault Shares", "sVault");
        decorator = new ConcreteVault(vault);
    }

    function test_deposit_should_fail_if_decorator_is_disabled() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);

        vm.expectRevert(DecorableVault.DecoratorIsNotCaller.selector);
        decorator.deposit(amount, depositor.addr);
        vm.stopPrank();
    }

    function test_deposit_is_execute_in_underlying_vault() public {
        vault.enableDecorator(address(decorator));
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);
        decorator.deposit(amount, depositor.addr);
        vm.stopPrank();

        assertEq(token.balanceOf(depositor.addr), 0 ether);
        assertEq(vault.balanceOf(depositor.addr), amount);
    }
}
