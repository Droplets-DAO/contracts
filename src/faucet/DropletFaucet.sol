/// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "src/interfaces/IERC20.sol";
import { IERC721 } from "src/interfaces/IERC721.sol";

contract DropletFaucet {
    IERC721 public immutable dropletNFT;
    IERC20 public immutable dripToken;

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
    uint256 internal lastSettledAuction;

    // All Dao proceeds owed, in Ether
    uint256 public DAORake;

    uint256 internal constant DRIP_PER_DAY_PER_DROPLET = 10 wei;

    constructor(address _dropletNFT, address _dripToken) {
        dropletNFT = IERC721(_dropletNFT);
        dripToken = IERC20(_dripToken);

        GENESIS = block.timestamp;
    }

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Bid(address indexed bidder, uint256 indexed amount, uint256 auction);
    event Extended(uint256 indexed endTime, uint256 indexed newTopBid);
    event Settled(uint256 indexed auction, address indexed winner, uint256 indexed amount);

    /*//////////////////////////////////////////////////////////////
                            EXT AUCTION LOGIC
    //////////////////////////////////////////////////////////////*/
    function startAuction() internal {
        uint256 dropletId = dropletNFT.mint(address(this));

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 1 days;

        auction = Auction({ dropletId: dropletId, amount: 0, startTime: startTime, endTime: endTime, bidder: payable(0), settled: false });
    }

    function startNextAuction() external {
        require(auction.settled = true, "DropletFaucet: Previous Auction not settled");
        if (GENESIS + FREE_FLOW_DURATION > block.timestamp) {
            // We can start auction right away then
            startAuction();
        } else {
            require(lastSettledAuction + 3 days < block.timestamp, "DropletFaucet: Too soon to start next auction");
            uint256 timeSince = block.timestamp - lastSettledAuction;
            // The cost in DRIP to start the next auction decays linearly at
            // y = (C - rt) where C is 40% of daily emissions, and C - rt equals 0 at 4 days
            uint256 totalPerDay = dropletNFT.totalSupply() * DRIP_PER_DAY_PER_DROPLET;
            uint256 c = (totalPerDay * 40) / 100;
            uint256 r = c / 4 days;

            // Cost is non-zero
            if (r * timeSince < c) {
                uint256 cost = c - (r * timeSince);
                dripToken.transferFrom(msg.sender, address(this), cost);
            }

            startAuction();
        }
    }

    // @dev FWIW dropletId is not *that* useful but stops weird block builder shennanigans
    function createBid(uint256 dropletId) external payable {
        Auction memory _auction = auction;

        require(auction.endTime > block.timestamp, "DropletFaucet: Auction has ended");
        require(_auction.dropletId == dropletId, "DropletFaucet: Droplet ID mismatch");
        // Must bid atleast last price + 5%
        require((_auction.amount * 105) / 100 < msg.value, "DropletFaucet: Bid too low");

        address payable lastBidder = _auction.bidder;

        // Refund the last bidder
        if (lastBidder != address(0)) {
            // If it doensn't work, it doesn't work
            bool success = lastBidder.send(_auction.amount);
            if (!success) {
                // Nouns would force WETH in this case
                // I am not that generous, this is simply our Ether now
                // Note - No donation attack vector, because we are simply just taking the money
                // They have no claim to it anymore
                DAORake += _auction.amount;
            }
        }

        auction.amount = msg.value;
        auction.bidder = payable(msg.sender);

        // Extend the auction if it's within the last 5 minutes
        if (auction.endTime - block.timestamp < 5 minutes) {
            auction.endTime += 5 minutes;

            emit Extended(auction.endTime, auction.amount);
        }

        emit Bid(msg.sender, msg.value, dropletId);
    }

    function settleAuction() external {
        Auction memory _auction = auction;

        // Some Basic Checks
        require(_auction.startTime > block.timestamp, "DropletFaucet: Auction has not started");
        require(_auction.endTime < block.timestamp, "DropletFaucet: Auction has not ended");
        require(!_auction.settled, "DropletFaucet: Auction already settled");

        // DAO takes 100% of proceeds
        DAORake += _auction.amount;

        // NOTE - `auction` is a storage variable reference, not `_auction` above which is in memory
        auction.settled = true;
        lastSettledAuction = block.timestamp;

        // Send the NFT to the winner
        dropletNFT.transferFrom(address(this), _auction.bidder, _auction.dropletId);
        
        emit Settled(_auction.dropletId, _auction.bidder, _auction.amount);
    }
}
