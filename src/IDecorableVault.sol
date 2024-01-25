// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";

interface IDecorableVault is IERC4626 {
    function enableDecorator(address decorator) external;

    function disableDecorator(address decorator) external;

    function getBalance(IERC20 token) external view returns (uint256);

    function getVault() external view returns (IERC4626);
}
