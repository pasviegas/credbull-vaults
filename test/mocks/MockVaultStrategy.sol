// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { AVaultStrategy } from "../../src/AVaultStrategy.sol";
import { IDecorableVault } from "../../src/IDecorableVault.sol";

contract MockVaultStrategy is AVaultStrategy {
    constructor(IDecorableVault vault) AVaultStrategy(vault) { }
}
