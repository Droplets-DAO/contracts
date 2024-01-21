// SPDX-License-Identifier: GPL-3.0

/// @title Interface for NounsSeeder

pragma solidity ^0.8.20;

import { IDropletDescriptorMinimal } from './IDropletDescriptorMinimal.sol';

interface IDropletSeeder {
    struct Seed {
        uint48 background;
        uint48 color;
        uint48 noggles;
        uint48 number;
        uint48 mood;
    }

    function generateSeed(uint256 nounId, IDropletDescriptorMinimal descriptor) external view returns (Seed memory);
}