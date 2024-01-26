// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { AVaultDecorator } from "../AVaultDecorator.sol";
import { IDecorableVault } from "../IDecorableVault.sol";
import { AKYCProvider } from "./AKYCProvider.sol";

contract WhitelistVaultDecorator is AVaultDecorator {
    error AddressNotAWhitelisted();

    AKYCProvider public provider;

    constructor(IDecorableVault _vault, AKYCProvider _provider) AVaultDecorator(_vault) {
        provider = _provider;
    }

    modifier onlyWhitelistedAddress(address receiver) {
        if (!provider.status(receiver)) {
            revert AddressNotAWhitelisted();
        }

        _;
    }

    function deposit(uint256 assets, address receiver)
    public
        override
        onlyWhitelistedAddress(receiver)
        onlyDecorator(msg.sender)
        returns (uint256 shares)
    {
        return vault.deposit(assets, receiver);
    }

    function mint(uint256 shares, address receiver)
    public
        override
        onlyWhitelistedAddress(receiver)
        onlyDecorator(msg.sender)
        returns (uint256 assets)
    {
        return vault.mint(shares, receiver);
    }
}
