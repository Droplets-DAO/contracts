// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import {ERC721} from "solmate/tokens/ERC721.sol";

import {IDropletDescriptorMinimal} from "../interfaces/IDropletDescriptorMinimal.sol";
import {IDropletSeeder} from "../interfaces/IDropletSeeder.sol";

contract DropletToken is ERC721("Droplet DAO NFT", "DROP") {
    // The Nouns token URI descriptor
    IDropletDescriptorMinimal public descriptor;

    // The Nouns token seeder
    IDropletSeeder public seeder;

    // The noun seeds
    mapping(uint256 => IDropletSeeder.Seed) public seeds;

    constructor(IDropletDescriptorMinimal _descriptor, IDropletSeeder _seeder) {
        descriptor = _descriptor;
        seeder = _seeder;
    }

    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return descriptor.tokenURI(tokenId, seeds[tokenId]);
    }

    /**
     * @notice Similar to `tokenURI`, but always serves a base64 encoded data URI
     * with the JSON contents directly inlined.
     */
    function dataURI(uint256 tokenId) public view returns (string memory) {
        return descriptor.dataURI(tokenId, seeds[tokenId]);
    }
}