// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IDecorableVault } from "./IDecorableVault.sol";

interface IDynamicAssetVault is IDecorableVault {
    function setTotalAssets(uint256 assets) external;
}
