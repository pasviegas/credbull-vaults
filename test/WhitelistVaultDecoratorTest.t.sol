// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { MockToken } from "./mocks/MockToken.sol";
import { DecorableVault } from "../src/DecorableVault.sol";
import { WhitelistVaultDecorator } from "../src/whitelist/WhitelistVaultDecorator.sol";
import { MockKYCProvider } from "./mocks/MockKYCProvider.sol";
import { MockVaultStrategy } from "./mocks/MockVaultStrategy.sol";

contract WhitelistVaultDecoratorTest is Test {
    MockToken public token;
    MockKYCProvider public provider;
    WhitelistVaultDecorator public decorator;
    MockVaultStrategy public strategy;
    DecorableVault public vault;

    Account public depositor;

    function setUp() public {
        depositor = makeAccount("depositor");

        token = new MockToken(1000 ether);
        vault = new DecorableVault(token, "Vault Shares", "sVault");

        provider = new MockKYCProvider();
        decorator = new WhitelistVaultDecorator(vault, provider);
        vault.enableDecorator(address(decorator));

        strategy = new MockVaultStrategy(decorator);
        decorator.enableDecorator(address(strategy));
    }

    function test_deposit_should_fail_if_address_not_whitelisted() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);

        vm.expectRevert(WhitelistVaultDecorator.AddressNotAWhitelisted.selector);
        strategy.deposit(amount, depositor.addr);
        vm.stopPrank();
    }

    function test_deposit_should_succeed_if_address_is_whitelisted() public {
        address[] memory whitelistAddresses = new address[](1);
        whitelistAddresses[0] = depositor.addr;
        bool[] memory statuses = new bool[](1);
        statuses[0] = true;
        provider.updateStatus(whitelistAddresses, statuses);

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
