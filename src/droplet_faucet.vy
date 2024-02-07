# @version 0.3.10

"""
@title droplet faucet
@author CopyPaste
@license GNU Affero General Public License v3.0
@notice An auction house for Droplet NFTs
"""

from vyper.interfaces import ERC721
from vyper.interfaces import ERC20

################################################################
#                        INTERFACES                            #
################################################################
interface Droplet:
    def mint(reciever: address) -> uint256: nonpayable
    def totalSupply() -> uint256: view

interface Blast:
    def configureClaimableGas(): nonpayable
    def configureGovernor(governor: address): nonpayable

blast: constant(address) = 0x4300000000000000000000000000000000000002

################################################################
#                            EVENTS                            #
################################################################
event Started:
    dropletId: indexed(uint256)
    startTime: indexed(uint256)
    endTime: indexed(uint256)

event Bid:
    bidder: indexed(address)
    amount: indexed(uint256)
    auction: uint256

event Extended:
    endTime: indexed(uint256)
    newTopBid: indexed(uint256)

event Settled:
    auction: uint256
    winner: indexed(address)
    amount: indexed(uint256)

################################################################
#                           STORAGE                            #
################################################################
struct Auction:
    # @dev The id of the droplet being auctioned
    dropletId: uint256
    # @dev The amount of the top bid
    amount: uint256
    # @dev The time the auction started
    start_time: uint256
    # @dev The time the auction ends
    end_time: uint256
    # @dev The address of the top bidder, payable in Ether
    bidder: address
    settled: bool

auction: public(Auction)
last_settled_auction: uint256

drip_token: public(immutable(ERC20))
droplet: public(immutable(address))

dao: public(address)
dao_treasure: public(uint256)

GENESIS: public(immutable(uint256))
FREE_FLOW_DURATION: public(constant(uint256)) = 50 * 86400 # 50 days
DRIP_PER_DROPLET: public(constant(uint256)) = 100

@external
def __init__(_droplet: address, _drip: address, _dao: address):
    droplet = _droplet
    drip_token = ERC20(_drip)
    self.dao = _dao

    GENESIS = block.timestamp

    self.auction.settled = True

    #Blast(blast).configureClaimableGas()
    #Blast(blast).configureGovernor(_dao)

################################################################
#                           AUCTION                            #
################################################################

@internal
def start_auction():
    droplet_id: uint256 = Droplet(droplet).mint(self)

    start_time: uint256 = block.timestamp
    end_time: uint256 = start_time + 86400

    self.auction = Auction({
        dropletId: droplet_id,
        amount: 0, # Minimum Bid Constant?
        start_time: start_time,
        end_time: end_time,
        bidder: empty(address),
        settled: False
    })

    log Started(droplet_id, start_time, end_time)

@external
def start_next_auction():
    assert self.auction.settled, "Auction not settled"
    if GENESIS + FREE_FLOW_DURATION > block.timestamp:
        self.start_auction()
    else:
        assert self.last_settled_auction + (86400 * 3) < block.timestamp, "Faucet is on cooldown"
        time_since: uint256 = block.timestamp - self.last_settled_auction

        total_per_day: uint256 = Droplet(droplet).totalSupply() * DRIP_PER_DROPLET
        # Price to start the next auction is equal to 30% of the total drip generated in the past day
        # decaying linearly over the next 4 days 
        thirty_percent: uint256 = (total_per_day * 30) / 100
        price: uint256 = thirty_percent - (thirty_percent * time_since) / (86400 * 4)

        if price > 0:
            drip_token.transferFrom(msg.sender, self, price)
        
        self.start_auction()

@payable
@external
def bid(droplet_id: uint256):
    """
        @param droplet_id Not completely neccessary but ensures bid arrives on time
            for the right auction
    """
    _auction: Auction = self.auction

    assert _auction.end_time > block.timestamp, "Auction has ended"
    assert _auction.dropletId == droplet_id, "Droplet ID mismatch"
    # Must bid atleast last price + 5%
    assert (_auction.amount * 105) / 100 < msg.value, "Bid too low"

    lastBidder: address = _auction.bidder

    if lastBidder != empty(address):
        send(lastBidder, _auction.amount)

    self.auction.amount = msg.value
    self.auction.bidder = msg.sender

    # Extend the auction if it's within the last 5 minutes
    if _auction.end_time - block.timestamp < 5 * 60:
        self.auction.end_time += 5 * 60

        log Extended(_auction.end_time + (5*60), msg.value)

    log Bid(msg.sender, msg.value, droplet_id)

@external
def settle_auction():
    _auction: Auction = self.auction

    assert _auction.end_time < block.timestamp, "DropletFaucet: Auction has not ended"
    assert not _auction.settled, "DropletFaucet: Auction already settled"

    # DAO takes 100% of proceeds
    self.dao_treasure += _auction.amount

    # NOTE - `auction` is a storage variable reference, not `_auction` above which is in memory
    self.auction.settled = True
    self.last_settled_auction = block.timestamp

    # Send the NFT to the winner
    ERC721(droplet).transferFrom(self, _auction.bidder, _auction.dropletId)

    log Settled(_auction.dropletId, _auction.bidder, _auction.amount)

