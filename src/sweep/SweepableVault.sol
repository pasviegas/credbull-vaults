// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { DecorableVault } from "../DecorableVault.sol";
import { ISweepableVault } from "./ISweepableVault.sol";

contract SweepableVault is ISweepableVault, DecorableVault {
    uint256 private _totalAssets;

    constructor(IERC20 asset, string memory name, string memory symbol) DecorableVault(asset, name, symbol) { }

    function sweep(uint256 assets, address receiver) public virtual onlyDecorator(msg.sender) {
        IERC20(asset()).approve(address(this), assets);
        SafeERC20.safeTransferFrom(IERC20(asset()), address(this), receiver, assets);
    }

    function setTotalAssets(uint256 assets) public virtual onlyDecorator(msg.sender) {
        _totalAssets = assets;
    }

    function totalAssets()
        public
        view
        virtual
        override(IERC4626, DecorableVault)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return _totalAssets;
    }
}
