// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { ERC4626 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IDecorableVault } from "./IDecorableVault.sol";

contract DecorableVault is IDecorableVault, ERC4626, Ownable {
    error DecoratorIsNotCaller();

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet internal decorators;

    constructor(IERC20 _asset, string memory _name, string memory _symbol)
        ERC4626(_asset)
        ERC20(_name, _symbol)
        Ownable(msg.sender)
    { }

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

    function asset() public view virtual override(IERC4626, ERC4626) onlyDecorator(msg.sender) returns (address) {
        return super.asset();
    }

    function totalAssets()
        public
        view
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.totalAssets();
    }

    function convertToShares(uint256 assets)
        public
        view
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.convertToShares(assets);
    }

    function convertToAssets(uint256 shares)
        public
        view
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.convertToAssets(shares);
    }

    function maxDeposit(address receiver)
        public
        view
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.maxDeposit(receiver);
    }

    function previewDeposit(uint256 assets)
        public
        view
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.previewDeposit(assets);
    }

    function deposit(uint256 assets, address receiver)
        public
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.deposit(assets, receiver);
    }

    function maxMint(address receiver)
        public
        view
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.maxMint(receiver);
    }

    function previewMint(uint256 shares)
        public
        view
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.previewMint(shares);
    }

    function mint(uint256 shares, address receiver)
        public
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.mint(shares, receiver);
    }

    function maxWithdraw(address owner)
        public
        view
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.maxWithdraw(owner);
    }

    function previewWithdraw(uint256 assets)
        public
        view
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.previewWithdraw(assets);
    }

    function withdraw(uint256 assets, address receiver, address owner)
        public
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.withdraw(assets, receiver, owner);
    }

    function maxRedeem(address owner)
        public
        view
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.maxRedeem(owner);
    }

    function previewRedeem(uint256 shares)
        public
        view
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.previewRedeem(shares);
    }

    function redeem(uint256 shares, address receiver, address owner)
        public
        virtual
        override(IERC4626, ERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.redeem(shares, receiver, owner);
    }

    function totalSupply() public view virtual override(IERC20, ERC20) onlyDecorator(msg.sender) returns (uint256) {
        return super.totalSupply();
    }

    function balanceOf(address account)
        public
        view
        virtual
        override(IERC20, ERC20)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.balanceOf(account);
    }

    function transfer(address to, uint256 value)
        public
        virtual
        override(IERC20, ERC20)
        onlyDecorator(msg.sender)
        returns (bool)
    {
        return super.transfer(to, value);
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override(IERC20, ERC20)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return super.allowance(owner, spender);
    }

    function approve(address spender, uint256 value)
        public
        virtual
        override(IERC20, ERC20)
        onlyDecorator(msg.sender)
        returns (bool)
    {
        return super.approve(spender, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public
        virtual
        override(IERC20, ERC20)
        onlyDecorator(msg.sender)
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

    function name()
        public
        view
        virtual
        override(ERC20, IERC20Metadata)
        onlyDecorator(msg.sender)
        returns (string memory)
    {
        return super.name();
    }

    function symbol()
        public
        view
        virtual
        override(ERC20, IERC20Metadata)
        onlyDecorator(msg.sender)
        returns (string memory)
    {
        return super.symbol();
    }

    function decimals()
        public
        view
        virtual
        override(ERC4626, IERC20Metadata)
        onlyDecorator(msg.sender)
        returns (uint8)
    {
        return super.decimals();
    }

    function _deposit(address caller, address receiver, uint256 assets, uint256 shares)
        internal
        virtual
        override
        onlyDecorator(caller)
    {
        SafeERC20.safeTransferFrom(IERC20(asset()), receiver, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(receiver, receiver, assets, shares);
    }

    function _withdraw(address caller, address receiver, address owner, uint256 assets, uint256 shares)
        internal
        virtual
        override
        onlyDecorator(caller)
    {
        if (receiver != owner) {
            _spendAllowance(owner, receiver, shares);
        }

        _burn(owner, shares);
        SafeERC20.safeTransfer(IERC20(asset()), receiver, assets);

        emit Withdraw(receiver, receiver, owner, assets, shares);
    }

    function getBalance(IERC20 token) public view virtual onlyDecorator(msg.sender) returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getVault() external view onlyDecorator(msg.sender) returns (IERC4626) {
        return this;
    }
}
