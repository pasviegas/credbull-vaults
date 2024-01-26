// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { AVaultDecorator } from "../AVaultDecorator.sol";
import { ISweepableVault } from "./ISweepableVault.sol";

contract ImmediateSweepVaultDecorator is AVaultDecorator, ISweepableVault {
    address public _custodian;

    constructor(ISweepableVault _vault, address custodian) AVaultDecorator(_vault) {
        _custodian = custodian;
    }

    function deposit(uint256 assets, address receiver)
    public
        override(AVaultDecorator, IERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        ISweepableVault sVault = ISweepableVault(address(vault));

        uint256 shares = sVault.deposit(assets, receiver);

        sVault.setTotalAssets(sVault.totalAssets() + assets);
        sVault.sweep(assets, _custodian);

        return shares;
    }

    function mint(uint256 shares, address receiver)
    public
        override(AVaultDecorator, IERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        ISweepableVault sVault = ISweepableVault(address(vault));

        uint256 assets = sVault.mint(shares, receiver);

        sVault.setTotalAssets(sVault.totalAssets() + assets);
        sVault.sweep(assets, _custodian);

        return assets;
    }

    function withdraw(uint256 assets, address receiver, address owner)
    public
        override(AVaultDecorator, IERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        ISweepableVault sVault = ISweepableVault(address(vault));

        uint256 shares = sVault.withdraw(assets, receiver, owner);
        sVault.setTotalAssets(sVault.totalAssets() - assets);

        return shares;
    }

    function redeem(uint256 shares, address receiver, address owner)
    public
        override(AVaultDecorator, IERC4626)
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        ISweepableVault sVault = ISweepableVault(address(vault));

        uint256 assets = sVault.redeem(shares, receiver, owner);
        sVault.setTotalAssets(sVault.totalAssets() - assets);

        return assets;
    }

    function sweep(uint256 assets, address receiver) public override onlyDecorator(msg.sender) {
        ISweepableVault sVault = ISweepableVault(address(vault));
        sVault.sweep(assets, receiver);
    }

    function setTotalAssets(uint256 assets) public override onlyDecorator(msg.sender) {
        ISweepableVault sVault = ISweepableVault(address(vault));
        sVault.setTotalAssets(assets);
    }
}
