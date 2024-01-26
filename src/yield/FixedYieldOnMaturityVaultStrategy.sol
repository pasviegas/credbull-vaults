// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AVaultStrategy } from "../../src/AVaultStrategy.sol";
import { FixedYieldOnMaturityVaultDecorator } from "./FixedYieldOnMaturityVaultDecorator.sol";

contract FixedYieldOnMaturityVaultStrategy is AVaultStrategy, Ownable {
    constructor(FixedYieldOnMaturityVaultDecorator vault) AVaultStrategy(vault) Ownable(msg.sender) { }

    function mature() external onlyOwner {
        FixedYieldOnMaturityVaultDecorator vault = FixedYieldOnMaturityVaultDecorator(address(vault));
        vault.mature();
    }
}
