// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IDynamicAssetVault } from "../IDynamicAssetVault.sol";

interface ISweepableVault is IDynamicAssetVault {
    function sweep(uint256 assets, address receiver) external;
}
