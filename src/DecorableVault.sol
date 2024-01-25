// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC4626 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IDecorableVault } from "./IDecorableVault.sol";

contract DecorableVault is IDecorableVault, ERC4626, Ownable {
    error DecoratorIsNotCaller();

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet internal decorators;

    constructor(IERC20 asset, string memory name, string memory symbol)
        ERC4626(asset)
        ERC20(name, symbol)
        Ownable(msg.sender)
    { }

    function enableDecorator(address decorator) external {
        decorators.add(decorator);
    }

    function disableDecorator(address decorator) external {
        decorators.remove(decorator);
    }

    modifier onlyDecorator(address caller) {
        if (!decorators.contains(caller)) {
            revert DecoratorIsNotCaller();
        }
        _;
    }

    function _deposit(address caller, address receiver, uint256 assets, uint256 shares)
        internal
        override
        onlyDecorator(caller)
    {
        SafeERC20.safeTransferFrom(IERC20(asset()), receiver, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(receiver, receiver, assets, shares);
    }

    function _withdraw(address caller, address receiver, address owner, uint256 assets, uint256 shares)
        internal
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
}
