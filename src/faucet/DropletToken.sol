/// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "lib/solmate/src/tokens/ERC721.sol";
import {Owned} from "lib/solmate/src/auth/Owned.sol";

contract DropletNFT is ERC721("Droplet DAO NFT", "DROP"), Owned(msg.sender) {
    constructor() {}

    function tokenURI(uint256 tokenId) public override pure returns (string memory) {
        return string.concat("https://droplet.wtf/tokenUris/", uint2str(tokenId));
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    uint256 public counter;

    function mint(address to) external onlyOwner returns (uint256) {
        counter++;
        _mint(to, counter);

        return counter;
    }
}