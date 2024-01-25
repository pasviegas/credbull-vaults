// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC4626 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { DecorableVault } from "../DecorableVault.sol";

contract SweepableVault is DecorableVault {
    uint256 private _totalAssetsDeposited;

    constructor(IERC20 asset, string memory name, string memory symbol) DecorableVault(asset, name, symbol) { }

    function sweep(uint256 assets, address receiver) public virtual onlyOwner {
        IERC20(asset()).approve(address(this), assets);
        SafeERC20.safeTransferFrom(IERC20(asset()), address(this), receiver, assets);
    }

    function setTotalAssetsDeposited(uint256 assets) public virtual onlyOwner {
        _totalAssetsDeposited = assets;
    }

    function totalAssets() public view virtual override(IERC4626, ERC4626) returns (uint256) {
        return _totalAssetsDeposited;
    }
}
