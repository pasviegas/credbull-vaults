// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { AVaultDecorator } from "../../src/AVaultDecorator.sol";
import { SweepableVault } from "./SweepableVault.sol";

contract ImmediateSweepVaultDecorator is AVaultDecorator {
    address public _custodian;

    constructor(SweepableVault _vault, address custodian) AVaultDecorator(_vault) {
        _custodian = custodian;
    }

    function deposit(uint256 assets, address receiver) external override returns (uint256) {
        SweepableVault sVault = SweepableVault(address(vault));

        uint256 shares = sVault.deposit(assets, receiver);

        sVault.setTotalAssetsDeposited(sVault.totalAssets() + assets);
        sVault.sweep(assets, _custodian);

        return shares;
    }

    function mint(uint256 shares, address receiver) external override returns (uint256) {
        SweepableVault sVault = SweepableVault(address(vault));

        uint256 assets = sVault.mint(shares, receiver);

        sVault.setTotalAssetsDeposited(sVault.totalAssets() + assets);
        sVault.sweep(assets, _custodian);

        return assets;
    }

    function withdraw(uint256 assets, address receiver, address owner) external override returns (uint256) {
        SweepableVault sVault = SweepableVault(address(vault));

        uint256 shares = sVault.withdraw(assets, receiver, owner);
        sVault.setTotalAssetsDeposited(sVault.totalAssets() - assets);

        return shares;
    }

    function redeem(uint256 shares, address receiver, address owner) external override returns (uint256) {
        SweepableVault sVault = SweepableVault(address(vault));

        uint256 assets = sVault.redeem(shares, receiver, owner);
        sVault.setTotalAssetsDeposited(sVault.totalAssets() - assets);

        return assets;
    }
}
