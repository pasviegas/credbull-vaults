// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { OperationWindowVaultDecorator } from "./OperationWindowVaultDecorator.sol";
import { IDecorableVault } from "../IDecorableVault.sol";

contract DepositWindowVaultDecorator is OperationWindowVaultDecorator {
    constructor(IDecorableVault _vault, uint256 depositOpensAt, uint256 depositClosesAt)
        OperationWindowVaultDecorator(_vault, depositOpensAt, depositClosesAt)
    { }

    function deposit(uint256 assets, address receiver)
    public
        override
        onlyInsideRequiredWindow("deposit")
        onlyDecorator(msg.sender)
        returns (uint256 shares)
    {
        return vault.deposit(assets, receiver);
    }

    function mint(uint256 shares, address receiver)
    public
        override
        onlyInsideRequiredWindow("mint")
        onlyDecorator(msg.sender)
        returns (uint256 assets)
    {
        return vault.mint(shares, receiver);
    }
}
