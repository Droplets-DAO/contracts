// SPDX-License-Identifier: GPL-3.0

/// @title The DropletToken pseudo-random seed generator

pragma solidity ^0.8.20;

import { IDropletDescriptorMinimal } from '../interfaces/IDropletDescriptorMinimal.sol';
import { IDropletSeeder } from '../interfaces/IDropletSeeder.sol';

contract DropletSeeder is IDropletSeeder {
    /**
     * @notice Generate a pseudo-random Noun seed using the previous blockhash and noun ID.
     */

    function generateSeed(uint256 nounId, IDropletDescriptorMinimal descriptor) external view override returns (Seed memory) {
        uint256 pseudorandomness = uint256(
            keccak256(abi.encodePacked(blockhash(block.number - 1), nounId))
        );

        uint256 backgroundCount = descriptor.backgroundCount();
        uint256 colorCount = descriptor.colorCount();
        uint256 nogglesCount = descriptor.nogglesCount();
        uint256 numberCount = descriptor.numberCount();
        uint256 moodCount = descriptor.moodCount();

        return Seed({
            background: uint48(
                uint48(pseudorandomness) % backgroundCount
            ),
            color: uint48(
                uint48(pseudorandomness >> 48) % colorCount
            ),
            noggles: uint48(
                uint48(pseudorandomness >> 96) % nogglesCount
            ),
            number: uint48(
                uint48(pseudorandomness >> 144) % numberCount
            ),
            mood: uint48(
                uint48(pseudorandomness >> 192) % moodCount
            )
        });
    }
}