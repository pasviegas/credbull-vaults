// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { MockToken } from "./mocks/MockToken.sol";
import { DecorableVault } from "../src/DecorableVault.sol";
import { OperationWindowVaultDecorator } from "../src/window/OperationWindowVaultDecorator.sol";
import { DepositWindowVaultDecorator } from "../src/window/DepositWindowVaultDecorator.sol";
import { RedeemWindowVaultDecorator } from "../src/window/RedeemWindowVaultDecorator.sol";
import { MockVaultStrategy } from "./mocks/MockVaultStrategy.sol";

contract WindowVaultDecoratorTest is Test {
    MockToken public token;
    DepositWindowVaultDecorator public depositDecorator;
    RedeemWindowVaultDecorator public decorator;
    MockVaultStrategy public strategy;
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

        redeemOpensAt = block.timestamp + 200;
        redeemClosesAt = block.timestamp + 210;
        decorator = new RedeemWindowVaultDecorator(depositDecorator, redeemOpensAt, redeemClosesAt);
        depositDecorator.enableDecorator(address(decorator));

        strategy = new MockVaultStrategy(decorator);
        decorator.enableDecorator(address(strategy));
    }

    function test_deposit_should_fail_if_before_deposit_window() public {
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
        strategy.deposit(amount, depositor.addr);
        vm.stopPrank();
    }

    function test_deposit_should_fail_if_after_deposit_window() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);

        vm.warp(depositClosesAt + 1);

        vm.expectRevert(
            abi.encodeWithSelector(
                OperationWindowVaultDecorator.OperationOutsideRequiredWindow.selector,
                "deposit",
                depositOpensAt,
                depositClosesAt,
                block.timestamp
            )
        );
        strategy.deposit(amount, depositor.addr);
        vm.stopPrank();
    }

    function test_deposit_should_succeed_if_between_deposit_window() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);

        vm.warp(depositClosesAt - 1);
        strategy.deposit(amount, depositor.addr);
        vm.stopPrank();

        assertEq(token.balanceOf(depositor.addr), 0 ether);
        assertEq(strategy.balanceOf(depositor.addr), amount);
    }

    function test_redeem_should_fail_if_before_redeem_window() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);

        vm.warp(depositClosesAt - 1);
        strategy.deposit(amount, depositor.addr);

        vm.warp(redeemOpensAt - 1);

        vm.expectRevert(
            abi.encodeWithSelector(
                OperationWindowVaultDecorator.OperationOutsideRequiredWindow.selector,
                "redeem",
                redeemOpensAt,
                redeemClosesAt,
                block.timestamp
            )
        );
        strategy.redeem(amount, depositor.addr, depositor.addr);
        vm.stopPrank();
    }

    function test_redeem_should_fail_if_after_redeem_window() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);

        vm.warp(depositClosesAt - 1);
        strategy.deposit(amount, depositor.addr);

        vm.warp(redeemClosesAt + 1);

        vm.expectRevert(
            abi.encodeWithSelector(
                OperationWindowVaultDecorator.OperationOutsideRequiredWindow.selector,
                "redeem",
                redeemOpensAt,
                redeemClosesAt,
                block.timestamp
            )
        );
        strategy.redeem(amount, depositor.addr, depositor.addr);
        vm.stopPrank();
    }

    function test_redeem_should_succeed_if_between_redeem_window() public {
        uint256 amount = 100 ether;

        token.mint(depositor.addr, amount);

        vm.startPrank(depositor.addr);
        token.approve(address(vault), amount);

        vm.warp(depositClosesAt - 1);
        strategy.deposit(amount, depositor.addr);

        vm.warp(redeemClosesAt - 1);
        strategy.redeem(amount, depositor.addr, depositor.addr);
        vm.stopPrank();

        assertEq(token.balanceOf(depositor.addr), amount);
        assertEq(strategy.balanceOf(depositor.addr), 0);
    }
}
