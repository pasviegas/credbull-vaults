// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { OperationWindowVaultDecorator } from "./OperationWindowVaultDecorator.sol";
import { IDecorableVault } from "../IDecorableVault.sol";

contract RedeemWindowVaultDecorator is OperationWindowVaultDecorator {
    constructor(IDecorableVault _vault, uint256 redeemOpensAt, uint256 redeemClosesAt)
        OperationWindowVaultDecorator(_vault, redeemOpensAt, redeemClosesAt)
    { }

    function withdraw(uint256 assets, address receiver, address owner)
        public
        override
        onlyInsideRequiredWindow("withdraw")
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return vault.withdraw(assets, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner)
        public
        override
        onlyInsideRequiredWindow("redeem")
        onlyDecorator(msg.sender)
        returns (uint256)
    {
        return vault.redeem(shares, receiver, owner);
    }
}
