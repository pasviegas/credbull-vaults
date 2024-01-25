// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { MockToken } from "./mocks/MockToken.sol";
import { DecorableVault } from "../src/DecorableVault.sol";
import { OperationWindowVaultDecorator } from "../src/window/OperationWindowVaultDecorator.sol";
import { DepositWindowVaultDecorator } from "../src/window/DepositWindowVaultDecorator.sol";
import { WhitelistVaultDecorator } from "../src/whitelist/WhitelistVaultDecorator.sol";
import { MockKYCProvider } from "./mocks/MockKYCProvider.sol";

contract WindowVaultDecoratorTest is Test {
    MockToken public token;
    DepositWindowVaultDecorator public depositDecorator;
    WhitelistVaultDecorator public decorator;
    MockKYCProvider public provider;
    DecorableVault public vault;

    Account public depositor;

    uint256 public depositOpensAt;
    uint256 public depositClosesAt;

    uint256 public redeemOpensAt;
    uint256 public redeemClosesAt;

    function setUp() public {
        depositor = makeAccount("depositor");

        token = new MockToken(1000 ether);
        vault = new DecorableVault(token, "Vault Shares", "sVault");

        depositOpensAt = block.timestamp + 10;
        depositClosesAt = block.timestamp + 100;
        depositDecorator = new DepositWindowVaultDecorator(vault, depositOpensAt, depositClosesAt);
        vault.enableDecorator(address(depositDecorator));

        provider = new MockKYCProvider();
        decorator = new WhitelistVaultDecorator(depositDecorator, provider);
        depositDecorator.enableDecorator(address(decorator));
    }

    function test_deposit_should_fail_if_address_not_whitelisted() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);

        vm.expectRevert(WhitelistVaultDecorator.AddressNotAWhitelisted.selector);
        decorator.deposit(amount, depositor.addr);
        vm.stopPrank();
    }

    function test_deposit_should_fail_if_before_deposit_window() public {
        address[] memory whitelistAddresses = new address[](1);
        whitelistAddresses[0] = depositor.addr;
        bool[] memory statuses = new bool[](1);
        statuses[0] = true;
        provider.updateStatus(whitelistAddresses, statuses);

        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);

        vm.expectRevert(
            abi.encodeWithSelector(
                OperationWindowVaultDecorator.OperationOutsideRequiredWindow.selector,
                "deposit",
                depositOpensAt,
                depositClosesAt,
                block.timestamp
            )
        );
        decorator.deposit(amount, depositor.addr);
        vm.stopPrank();
    }

    function test_deposit_should_succeed_if_between_deposit_window_and_whitelisted() public {
        address[] memory whitelistAddresses = new address[](1);
        whitelistAddresses[0] = depositor.addr;
        bool[] memory statuses = new bool[](1);
        statuses[0] = true;
        provider.updateStatus(whitelistAddresses, statuses);

        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);

        vm.warp(depositClosesAt - 1);
        decorator.deposit(amount, depositor.addr);
        vm.stopPrank();

        assertEq(token.balanceOf(depositor.addr), 0 ether);
        assertEq(vault.balanceOf(depositor.addr), amount);
    }
}
