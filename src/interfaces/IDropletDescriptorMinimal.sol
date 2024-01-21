// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/// @title Common interface for DropletDescriptor versions, as used by DropletToken and DropletSeeder.

import { IDropletSeeder } from './IDropletSeeder.sol';

interface IDropletDescriptorMinimal {
    ///
    /// USED BY TOKEN
    ///

    function tokenURI(uint256 tokenId, IDropletSeeder.Seed memory seed) external view returns (string memory);

    function dataURI(uint256 tokenId, IDropletSeeder.Seed memory seed) external view returns (string memory);

    ///
    /// USED BY SEEDER
    ///

    function backgroundCount() external view returns (uint256);

    function nogglesCount() external view returns (uint256);

    function colorCount() external view returns (uint256);

    function numberCount() external view returns (uint256);

    function moodCount() external view returns (uint256);
}