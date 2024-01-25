// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Math } from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import { AVaultDecorator } from "../AVaultDecorator.sol";
import { IDynamicAssetVault } from "../IDynamicAssetVault.sol";

contract FixedYieldOnMaturityVaultDecorator is AVaultDecorator, Ownable, IDynamicAssetVault {
    using Math for uint256;

    error VaultNotMatured();
    error NotEnoughBalanceToMature();

    bool public isMatured;

    uint256 private _fixedYield;

    modifier onlyIfMatured() {
        if (!isMatured) revert VaultNotMatured();

        _;
    }

    constructor(IDynamicAssetVault _vault, uint256 fixedYield) AVaultDecorator(_vault) Ownable(msg.sender) {
        _fixedYield = fixedYield;
    }

    function withdraw(uint256 assets, address receiver, address owner)
        external
        override(AVaultDecorator, IERC4626)
        onlyIfMatured
        returns (uint256)
    {
        return vault.withdraw(assets, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner)
        external
        override(AVaultDecorator, IERC4626)
        onlyIfMatured
        returns (uint256 assets)
    {
        return vault.redeem(shares, receiver, owner);
    }

    function expectedAssetsOnMaturity() public view returns (uint256) {
        return vault.totalAssets().mulDiv(100 + _fixedYield, 100);
    }

    function setTotalAssets(uint256 assets) public virtual onlyOwner {
        IDynamicAssetVault(address(vault)).setTotalAssets(assets);
    }

    function mature() external onlyOwner {
        uint256 currentBalance = vault.getBalance(IERC20(vault.asset()));

        if (expectedAssetsOnMaturity() > currentBalance) {
            revert NotEnoughBalanceToMature();
        }

        setTotalAssets(currentBalance);

        isMatured = true;
    }
}
