// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AKYCProvider } from "../../src/whitelist/AKYCProvider.sol";

contract MockKYCProvider is AKYCProvider, Ownable {
    error LengthMismatch();

    mapping(address => bool) public isWhitelisted;

    constructor() Ownable(msg.sender) { }

    function status(address receiver) public view override returns (bool) {
        return isWhitelisted[receiver];
    }

    function updateStatus(address[] calldata _addresses, bool[] calldata _statuses) external override onlyOwner {
        if (_addresses.length != _statuses.length) revert LengthMismatch();

        uint256 length = _addresses.length;

        for (uint256 i; i < length;) {
            isWhitelisted[_addresses[i]] = _statuses[i];

            unchecked {
                ++i;
            }
        }
    }
}
