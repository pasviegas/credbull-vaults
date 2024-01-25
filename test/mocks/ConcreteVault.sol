// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { AVaultDecorator } from "../../src/AVaultDecorator.sol";
import { IDecorableVault } from "../../src/IDecorableVault.sol";

contract ConcreteVault is AVaultDecorator {
    constructor(IDecorableVault vault) AVaultDecorator(vault) { }
}
