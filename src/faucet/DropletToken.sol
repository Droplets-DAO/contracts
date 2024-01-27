/// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ERC721 } from "lib/solmate/src/tokens/ERC721.sol";
import { Owned } from "lib/solmate/src/auth/Owned.sol";

import { FixedPointMathLib } from "lib/solady/src/utils/FixedPointMathLib.sol";


contract DropletNFT is ERC721("Droplet DAO NFT", "DROP"), Owned(msg.sender) {
    /// @notice The total number of Droplets in Existence, also doubles as counter for minting
    uint256 public totalSupply;

    /// @notice The auction house where Droplets are minted and offered for sale
    address public auctionHouse;

    /// @notice We allow a pre-mint for early supporteres and devs
    constructor(address[] memory reservedDroplets) {
        uint256 _totalSupply = 0;
        for (uint256 i = 0; i < reservedDroplets.length; ++i) {
            _totalSupply++;
            _mint(reservedDroplets[i], _totalSupply);
        }
    }

    function tokenURI(uint256 tokenId) public pure override returns (string memory) {
        return string.concat("https://droplet.wtf/tokenUris/", toString(tokenId));
    }

    /// @dev Converts a `uint256` to its ASCII `string` decimal representation.
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = FixedPointMathLib.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), "0123456789abcdef"))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    function setAuctionHouse(address newAuctionHouse) external onlyOwner {
        auctionHouse = newAuctionHouse;
    }

    modifier onlyAuctionHouse {
        require(msg.sender == address(auctionHouse), "DropletNFT: Only the Auction House can call this function");
        _;
    }
    
    /// @dev mint function allowed by only the auction house
    function mint(address to) external onlyAuctionHouse returns (uint256) {
        totalSupply++;

        // Internal Mint Function, we supply totalSupply as 
        // our `counter` value
        _mint(to, totalSupply);
        
        return totalSupply;
    }
}
