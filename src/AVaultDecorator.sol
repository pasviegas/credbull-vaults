// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { IDecorableVault } from "./IDecorableVault.sol";

abstract contract AVaultDecorator is IDecorableVault, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    error DecoratorIsNotCaller();

    EnumerableSet.AddressSet internal decorators;
    IDecorableVault internal vault;

    constructor(IDecorableVault _vault) Ownable(msg.sender) {
        vault = _vault;
    }

    function enableDecorator(address decorator) external onlyOwner {
        decorators.add(decorator);
    }

    function disableDecorator(address decorator) external onlyOwner {
        decorators.remove(decorator);
    }

    modifier onlyDecorator(address caller) {
        if (!decorators.contains(caller)) {
            revert DecoratorIsNotCaller();
        }
        _;
    }

    function asset() public view virtual onlyDecorator(msg.sender) returns (address) {
        return vault.asset();
    }

    function totalAssets() public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.totalAssets();
    }

    function convertToShares(uint256 assets) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.convertToShares(assets);
    }

    function convertToAssets(uint256 shares) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.convertToAssets(shares);
    }

    function maxDeposit(address receiver) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.maxDeposit(receiver);
    }

    function previewDeposit(uint256 assets) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.previewDeposit(assets);
    }

    function deposit(uint256 assets, address receiver) public virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.deposit(assets, receiver);
    }

    function maxMint(address receiver) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.maxMint(receiver);
    }

    function previewMint(uint256 shares) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.previewMint(shares);
    }

    function mint(uint256 shares, address receiver) public virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.mint(shares, receiver);
    }

    function maxWithdraw(address owner) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.maxWithdraw(owner);
    }

    function previewWithdraw(uint256 assets) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.previewWithdraw(assets);
    }

    function withdraw(uint256 assets, address receiver, address owner)
        public
        virtual
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return vault.withdraw(assets, receiver, owner);
    }

    function maxRedeem(address owner) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.maxRedeem(owner);
    }

    function previewRedeem(uint256 shares) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.previewRedeem(shares);
    }

    function redeem(uint256 shares, address receiver, address owner)
        public
        virtual
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return vault.redeem(shares, receiver, owner);
    }

    function totalSupply() public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.totalSupply();
    }

    function balanceOf(address account) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.balanceOf(account);
    }

    function transfer(address to, uint256 value) public virtual onlyDecorator(msg.sender) returns (bool) {
        return vault.transfer(to, value);
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return vault.allowance(owner, spender);
    }

    function approve(address spender, uint256 value) public virtual onlyDecorator(msg.sender) returns (bool) {
        return vault.approve(spender, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public
        virtual
        onlyDecorator(msg.sender)
        returns (bool)
    {
        return vault.transferFrom(from, to, value);
    }

    function name() public view virtual onlyDecorator(msg.sender) returns (string memory) {
        return vault.name();
    }

    function symbol() public view virtual onlyDecorator(msg.sender) returns (string memory) {
        return vault.symbol();
    }

    function decimals() public view virtual onlyDecorator(msg.sender) returns (uint8) {
        return vault.decimals();
    }

    function getBalance(IERC20 token) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return vault.getBalance(token);
    }

    function getVault() public view onlyDecorator(msg.sender) returns (IERC4626) {
        return vault.getVault();
    }
}
