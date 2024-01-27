/// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "src/interfaces/IERC20.sol";
import {IERC721} from "src/interfaces/IERC721.sol";

contract DropletFaucet {
    IERC20 public immutable deth;
    IERC721 public immutable dropletNFT;

    uint256 constant FREE_FLOW_DURATION = 50 days;
    uint256 immutable GENESIS;

    struct Auction {
        // ID for the Droplet (ERC721 token ID)
        uint256 dropletId;
        // The current highest bid amount
        uint256 amount;
        // The time that the auction started
        uint256 startTime;
        // The time that the auction is scheduled to end
        uint256 endTime;
        // The address of the current highest bid
        address payable bidder;
        // Whether or not the auction has been settled
        bool settled;
    }

    Auction public auction;

    constructor(address _deth, address _dropletNFT) {
        deth = IERC20(_deth);
        dropletNFT = IERC721(_dropletNFT);

        GENESIS = block.timestamp;
    }

    function startAuction() internal {
        uint256 dropletId = dropletNFT.mint(address(this));

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 1 days;

        auction = Auction({
            dropletId: dropletId,
            amount: 0,
            startTime: startTime,
            endTime: endTime,
            bidder: payable(0),
            settled: false
        });

    }
}