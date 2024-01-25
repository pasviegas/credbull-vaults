// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { AVaultDecorator } from "../../src/AVaultDecorator.sol";
import { IDecorableVault } from "../IDecorableVault.sol";

abstract contract OperationWindowVaultDecorator is AVaultDecorator {
    error OperationOutsideRequiredWindow(
        string operation, uint256 windowOpensAt, uint256 windowClosesAt, uint256 timestamp
    );

    uint256 public windowOpensAt;
    uint256 public windowClosesAt;

    constructor(IDecorableVault _vault, uint256 _windowOpensAt, uint256 _windowClosesAt) AVaultDecorator(_vault) {
        windowOpensAt = _windowOpensAt;
        windowClosesAt = _windowClosesAt;
    }

    modifier onlyInsideRequiredWindow(string memory operation) {
        if (block.timestamp < windowOpensAt || block.timestamp > windowClosesAt) {
            revert OperationOutsideRequiredWindow(operation, windowOpensAt, windowClosesAt, block.timestamp);
        }

        _;
    }
}
