// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { Math } from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import { AVaultDecorator } from "../AVaultDecorator.sol";
import { IDynamicAssetVault } from "../IDynamicAssetVault.sol";

contract FixedYieldOnMaturityVaultDecorator is AVaultDecorator, IDynamicAssetVault {
    using Math for uint256;

    error VaultNotMatured();
    error NotEnoughBalanceToMature();

    bool public isMatured;

    uint256 private _fixedYield;

    constructor(IDynamicAssetVault _vault, uint256 fixedYield) AVaultDecorator(_vault) {
        _fixedYield = fixedYield;
    }

    modifier onlyIfMatured() {
        if (!isMatured) revert VaultNotMatured();

        _;
    }

    function withdraw(uint256 assets, address receiver, address owner)
    public
        override(AVaultDecorator, IERC4626)
        onlyIfMatured
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return vault.withdraw(assets, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner)
    public
        override(AVaultDecorator, IERC4626)
        onlyIfMatured
        onlyDecorator(msg.sender)
        returns (uint256 assets)
    {
        return vault.redeem(shares, receiver, owner);
    }

    function expectedAssetsOnMaturity() public view onlyDecorator(msg.sender) returns (uint256) {
        return vault.totalAssets().mulDiv(100 + _fixedYield, 100);
    }

    function setTotalAssets(uint256 assets) public virtual onlyDecorator(msg.sender) {
        IDynamicAssetVault(address(vault)).setTotalAssets(assets);
    }

    function mature() public onlyDecorator(msg.sender) {
        uint256 currentBalance = vault.getBalance(IERC20(vault.asset()));

        if (expectedAssetsOnMaturity() > currentBalance) {
            revert NotEnoughBalanceToMature();
        }

        setTotalAssets(currentBalance);

        isMatured = true;
    }
}
