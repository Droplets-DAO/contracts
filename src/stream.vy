# @pragma 0.3.10

"""
@title stream
@author CopyPaste
@license GNU Affero General Public License v3.0
@notice Very complex contract, so read carefully, but allow bonding of NFTs and ETH for liquidity
"""

from vyper.interfaces import ERC721


enum PoolType:
    TOKEN
    NFT
    TRADE

interface LSSVM2Factory:
    def createPairERC721ETH(
        nft: address,
        bondingCurve: address,
        assetRecipient: address,
        poolType: PoolType,
        delta: uint128,
        fee: uint96,
        spotPrice: uint128,
        propertyChecker: address,
        initial_nft_ids: DynArray[uint256, 5]
    ) -> address: payable

    def depositNFTs(_nft: address, ids: DynArray[uint256, 5], recipient: address): nonpayable


################################################################
#                           STORAGE                            #
################################################################

struct Bond:
    nft: uint256
    maturity: uint256
    owner: address

bonded_nft: public(immutable(address))
factory: public(immutable(address))
pair: public(immutable(address))
ether_funded: public(immutable(uint256))

nfts_bonded: public(HashMap[address, uint256])
nft_bonds: public(HashMap[uint256, Bond])

fees_earned: public(uint256)

@payable
@external
def __init__(_factory: address, _nft: address, _curve: address, _delta: uint128, _fee: uint96, _spotPrice: uint128, _propertyChecker: address):
    factory = _factory
    bonded_nft = _nft

    ether_funded = msg.value

    pair = LSSVM2Factory(_factory).createPairERC721ETH(
        _nft,
        _curve,
        self,
        PoolType.NFT,
        _delta,
        _fee,
        _spotPrice,
        _propertyChecker,
        [],
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
def bond_nft(id: uint256):
    """
        @param id The tokenId to bond
    """

    ERC721(bonded_nft).transferFrom(msg.sender, self, id)

    self.nfts_bonded[msg.sender] += 1
    # Move as an array to match the function signature
    ids: DynArray[uint256, 1] = [id]
    LSSVM2Factory(factory).depositNFTs(bonded_nft, ids, pair)

    # Mint them a bond
    self.nft_bonds[id] = Bond({
        nft: id,
        maturity: block.timestamp + (30 * 86400),
        owner: msg.sender
    })

@external
def redeem_bond(bond_id: uint256):
    """
        @param bond_id The bond to redeem
    """

    bond: Bond = self.nft_bonds[bond_id]

    assert bond.owner == msg.sender, "You do not own this bond"
    assert bond.maturity < block.timestamp, "Bond has not matured"

    # Calculate PnL or something here?