// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";

interface IDecorableVault is IERC4626 {
    function enableDecorator(address decorator) external;

    function disableDecorator(address decorator) external;
}
