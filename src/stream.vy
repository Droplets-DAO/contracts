# @pragma 0.3.10

"""
@title stream
@author CopyPaste
@license GNU Affero General Public License v3.0
"""

from vyper.interfaces import ERC721


enum CurveErrors:
    OK # No error
    INVALID_NUMITEMS # The numItem value is 0
    SPOT_PRICE_OVERFLOW # The updated spot price doesn't fit into 128 bits
    DELTA_OVERFLOW # The updated delta doesn't fit into 128 bits
    SPOT_PRICE_UNDERFLOW # The updated spot price goes too low
    AUCTION_ENDED # The auction has ended

interface LSSVM2Factory:
    def createPairERC721ETH(
        nft: address,
        bondingCurve: address,
        assetRecipient: address,
        poolType: uint8,
        delta: uint128,
        fee: uint96,
        spotPrice: uint128,
        propertyChecker: address,
        initial_nft_ids: DynArray[uint256, 5],
        hookAddress: address,
        _referralAddress: address
    ) -> address: payable

    def depositNFTs(_nft: address, ids: DynArray[uint256, 5], recipient: address): nonpayable

interface LSSVM2Pair:
    def getSellNFTQuote(assetId: uint256, numNFTs: uint256) -> (
        CurveErrors,
        uint256, # newSpotPrice
        uint256, # newDelta
        uint256, # outputAmount
        uint256, # protocolFee
        uint256 # royaltyAmount
    ): view

    def withdrawERC721(nft: address, nftIds: DynArray[uint256, 1]): nonpayable

################################################################
#                           STORAGE                            #
################################################################

struct Bond:
    owner: address
    maturity: uint256
    price: uint256
    fee_snapshot: uint256

bonded_nft: public(immutable(address))
factory: public(immutable(address))
pair: public(immutable(address))
ether_funded: public(immutable(uint256))

bonds_issued: public(uint256)
nft_bonds: public(HashMap[uint256, Bond])

fees_earned: public(uint256)

@payable
@external
def __init__(_factory: address, _nft: address, _curve: address, _delta: uint128, _fee: uint96, _spotPrice: uint128, _propertyChecker: address):
    """
        @param _factory The Sudoswap pair factory
        @param _nft The address of the ERC721 we are selling bonds for
        @param _curve the Curve we want to market make along
    """
    factory = _factory
    bonded_nft = _nft

    ether_funded = msg.value

    pair = LSSVM2Factory(_factory).createPairERC721ETH(
        _nft,
        _curve,
        self,
        2,
        _delta,
        _fee,
        _spotPrice,
        _propertyChecker,
        [],
        empty(address),
        msg.sender,
        value=msg.value
    )

    ERC721(_nft).setApprovalForAll(pair, True)

@payable
@external
def __default__():
    """
        @notice Fallback function, which is where we receive ETH earned as fees from the pool
    """
    self.fees_earned += msg.value
    
@external
def bond_nft(id: uint256) -> uint256:
    """
        @param id The tokenId to bond
    """

    ERC721(bonded_nft).transferFrom(msg.sender, self, id)

    # Move as an array to match the function signature
    ids: DynArray[uint256, 1] = [id]
    LSSVM2Factory(factory).depositNFTs(bonded_nft, ids, pair)

    bond_id: uint256 = self.bonds_issued + 1
    self.bonds_issued = bond_id

    # Get the price
    error: CurveErrors = CurveErrors.OK
    new_spot_price: uint256 = 0
    new_delta: uint256 = 0
    output_amount: uint256 = 0
    protocol_fee: uint256 = 0
    royalty_amount: uint256 = 0

    error, new_spot_price, new_delta, output_amount, protocol_fee, royalty_amount = LSSVM2Pair(pair).getSellNFTQuote(id, 1)

    assert error == CurveErrors.OK, "Error getting quote"

    # Mint them a bond
    self.nft_bonds[bond_id] = Bond({
        owner: msg.sender,
        maturity: block.timestamp + (86400 * 30),
        price: output_amount,
        fee_snapshot: self.fees_earned
    })

    return bond_id

@external
def redeem_bond(bond_id: uint256, id: uint256):
    """
        @param bond_id The bond to redeem
        @param id The nft to be returned for the bond
    """

    bond: Bond = self.nft_bonds[bond_id]

    assert bond.owner == msg.sender, "You do not own this bond"
    assert bond.maturity < block.timestamp, "Bond has not matured"

    # Get the current price
    error: CurveErrors = CurveErrors.OK
    new_spot_price: uint256 = 0
    new_delta: uint256 = 0
    output_amount: uint256 = 0
    protocol_fee: uint256 = 0
    royalty_amount: uint256 = 0

    error, new_spot_price, new_delta, output_amount, protocol_fee, royalty_amount = LSSVM2Pair(pair).getSellNFTQuote(0, 1)

    assert error == CurveErrors.OK, "Error getting quote"

    if output_amount > bond.price:
        # This means we made a profit, so we pay them 50% of fees + give them back an NFT
        # We may need to check on this later, not entirely sure this works
        fees_owed: uint256 = self.fees_earned - bond.fee_snapshot
        send(msg.sender, fees_owed)

        # Pay them back their NFT
        LSSVM2Pair(pair).withdrawERC721(bonded_nft, [id])
        ERC721(bonded_nft).transferFrom(self, msg.sender, id)

        # delete the bond
        self.nft_bonds[bond_id] = Bond({
            owner: empty(address),
            maturity: 0,
            price: 0,
            fee_snapshot: 0
        })

        return
    else:
        # Price went down, so pool should have more NFTs than Eth, so we eat the loss and refund them the NFT
        LSSVM2Pair(pair).withdrawERC721(bonded_nft, [id])
        ERC721(bonded_nft).transferFrom(self, msg.sender, id)

        # Burn the bond
        self.nft_bonds[bond_id] = Bond({
            owner: empty(address),
            maturity: 0,
            price: 0,
            fee_snapshot: 0
        })

        return