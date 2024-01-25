// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { IDecorableVault } from "./IDecorableVault.sol";

abstract contract AVaultDecorator is IDecorableVault {
    IDecorableVault internal vault;

    constructor(IDecorableVault _vault) {
        vault = _vault;
    }

    function enableDecorator(address decorator) external virtual {
        vault.enableDecorator(decorator);
    }

    function disableDecorator(address decorator) external virtual {
        vault.disableDecorator(decorator);
    }

    function asset() external view virtual returns (address assetTokenAddress) {
        return vault.asset();
    }

    function totalAssets() external view virtual returns (uint256 totalManagedAssets) {
        return vault.totalAssets();
    }

    function convertToShares(uint256 assets) external view virtual returns (uint256 shares) {
        return vault.convertToShares(assets);
    }

    function convertToAssets(uint256 shares) external view virtual returns (uint256 assets) {
        return vault.convertToAssets(shares);
    }

    function maxDeposit(address receiver) external view virtual returns (uint256 maxAssets) {
        return vault.maxDeposit(receiver);
    }

    function previewDeposit(uint256 assets) external view virtual returns (uint256 shares) {
        return vault.previewDeposit(assets);
    }

    function deposit(uint256 assets, address receiver) external virtual returns (uint256 shares) {
        return vault.deposit(assets, receiver);
    }

    function maxMint(address receiver) external view virtual returns (uint256 maxShares) {
        return vault.maxMint(receiver);
    }

    function previewMint(uint256 shares) external view virtual returns (uint256 assets) {
        return vault.previewMint(shares);
    }

    function mint(uint256 shares, address receiver) external virtual returns (uint256 assets) {
        return vault.mint(shares, receiver);
    }

    function maxWithdraw(address owner) external view virtual returns (uint256 maxAssets) {
        return vault.maxWithdraw(owner);
    }

    function previewWithdraw(uint256 assets) external view virtual returns (uint256 shares) {
        return vault.previewWithdraw(assets);
    }

    function withdraw(uint256 assets, address receiver, address owner) external virtual returns (uint256 shares) {
        return vault.withdraw(assets, receiver, owner);
    }

    function maxRedeem(address owner) external view virtual returns (uint256 maxShares) {
        return vault.maxRedeem(owner);
    }

    function previewRedeem(uint256 shares) external view virtual returns (uint256 assets) {
        return vault.previewRedeem(shares);
    }

    function redeem(uint256 shares, address receiver, address owner) external virtual returns (uint256 assets) {
        return vault.redeem(shares, receiver, owner);
    }

    function totalSupply() external view virtual returns (uint256) {
        return vault.totalSupply();
    }

    function balanceOf(address account) external view virtual returns (uint256) {
        return vault.balanceOf(account);
    }

    function transfer(address to, uint256 value) external virtual returns (bool) {
        return vault.transfer(to, value);
    }

    function allowance(address owner, address spender) external view virtual returns (uint256) {
        return vault.allowance(owner, spender);
    }

    function approve(address spender, uint256 value) external virtual returns (bool) {
        return vault.approve(spender, value);
    }

    function transferFrom(address from, address to, uint256 value) external virtual returns (bool) {
        return vault.transferFrom(from, to, value);
    }

    function name() external view virtual returns (string memory) {
        return vault.name();
    }

    function symbol() external view virtual returns (string memory) {
        return vault.symbol();
    }

    function decimals() external view virtual returns (uint8) {
        return vault.decimals();
    }

    function getBalance(IERC20 token) public view virtual returns (uint256) {
        return vault.getBalance(token);
    }

    function getVault() external view returns (IERC4626) {
        return vault.getVault();
    }
}
