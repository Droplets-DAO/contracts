# @pragma 0.3.10

"""
@title droplet nft
@author CopyPaste
@license GNU Affero General Public License v3.0
@notice The Core Droplet NFT Contract
"""

interface ERC721Reciever:
    def onERC721Received(a: address, b: address, c: uint256, d: Bytes[1024]) -> bytes4: nonpayable

interface DRIP:
    def init_id(id: uint256): nonpayable

interface BLAST:
    def configureClaimableGas(): nonpayable
    def configureClaimableYield(): nonpayable
    def claimAllYield(contractAddress: address, recipientOfYield: address) -> uint256: nonpayable
    def claimAllGas(contractAddress: address, recipientOfGas: address) -> uint256: nonpayable
    
interface IBLASTPointsOperator:
    def configurePointsOperator(op: address): nonpayable

################################################################
#                            EVENTS                            #
################################################################
event Transfer:
    _from: indexed(address)
    to: indexed(address)
    tokenId: indexed(uint256)

event Approval:
    owner: indexed(address)
    account: indexed(address)
    id: indexed(uint256)

event ApprovalForAll:
    owner: indexed(address)
    operator: indexed(address)
    isApproved: bool

################################################################
#                           METADATA                           #
################################################################

name: public(immutable(String[25]))

symbol: public(immutable(String[5]))


################################################################
#                           STORAGE                            #
################################################################

ownerOf: public(HashMap[uint256, address])
balanceOf: public(HashMap[address, uint256])

get_approved: public(HashMap[uint256, address])
isApprovedForAll: public(HashMap[address, HashMap[address, bool]])

owner: public(address)
minters: public(HashMap[address, bool])
totalSupply: public(uint256)

claimed_premints: public(bool)

drip: public(address)

@external
def __init__():
    name = "Droplet NFT"
    symbol = "DROP"

    BLAST(0x4300000000000000000000000000000000000002).configureClaimableGas()
    BLAST(0x4300000000000000000000000000000000000002).configureClaimableYield()

    IBLASTPointsOperator(0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800).configurePointsOperator(0x3f2e5ED8d1Ff052553b0837d5eC7ceca952C19Cd)

    self.owner = 0x0e0A927fE11353d493DA8444490938DAe8FDAa7e
    self.minters[msg.sender] = True

@external
def claim_premints():
    assert not self.claimed_premints, "ALREADY CLAIMED"
    




    self._mint(0x75d4bdBf6593ed463e9625694272a0FF9a6D346F)
    self._mint(0x3f2e5ED8d1Ff052553b0837d5eC7ceca952C19Cd)
    self._mint(0x8907d622d48801f9B5918Ef619c159b33BFC5208)
    self._mint(0x8907d622d48801f9B5918Ef619c159b33BFC5208)
    self._mint(0x3f2e5ED8d1Ff052553b0837d5eC7ceca952C19Cd)
    self._mint(0x3f2e5ED8d1Ff052553b0837d5eC7ceca952C19Cd)
    self._mint(0x8907d622d48801f9B5918Ef619c159b33BFC5208)
    self._mint(0xc27FD9D5113dE19EA89D0265Be9FD93F35f052c8)
    self._mint(0xE8517418753eAe2c158ae413255f7DfedF18B2E4)
    self._mint(0x0ca85b489A1276eF7042F1d032D0eF3831EaF4ca)
    self._mint(0x0ca85b489A1276eF7042F1d032D0eF3831EaF4ca)
    self._mint(0x0ca85b489A1276eF7042F1d032D0eF3831EaF4ca)
    self._mint(0xbcD2E843FE41Da351cDe58bceB40D69242b229Db)
    self._mint(0x90649222cBD82Ea2fbD6f99848Cf474dac51F71b)
    self._mint(0x90649222cBD82Ea2fbD6f99848Cf474dac51F71b)

    self.claimed_premints = True


@external
def claim_money(account: address):
    assert msg.sender == self.owner, "NOT OWNER"

    BLAST(0x4300000000000000000000000000000000000002).claimAllYield(self, account)
    BLAST(0x4300000000000000000000000000000000000002).claimAllGas(self, account)

@external
def init_drip(drip_address: address):
    assert msg.sender == self.owner, "NOT OWNER"
    self.drip = drip_address

@external
def change_owner(new_owner: address):
    assert msg.sender == self.owner, "NOT_AUTHORIZED"
    self.owner = new_owner

################################################################
#                            ERC721                            #
################################################################
@external
def approve(spender: address, id: uint256):
    """
        @param spender The approved spender
        @param id The token id to be approved
    """
    owner: address = self.ownerOf[id]

    assert msg.sender == owner or self.isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED"

    self.get_approved[id] = spender

    log Approval(owner, spender, id)

@external
def setApprovalForAll(operator: address, approved: bool):
    """
        @param operator The address approved to send all nfts
        @param approved Toggle for global approval
    """
    self.isApprovedForAll[msg.sender][operator] = approved

    log ApprovalForAll(msg.sender, operator, approved)

@internal
def transfer_from(_from: address, to: address, id: uint256):
    assert _from == self.ownerOf[id], "WRONG_FROM"
    assert to != empty(address), "INVALID_RECIPIENT"

    assert msg.sender == _from or self.isApprovedForAll[_from][msg.sender] or msg.sender == self.get_approved[id], "Not Authorized"

    self.balanceOf[_from] = unsafe_sub(self.balanceOf[_from], 1)
    self.balanceOf[to] = unsafe_sub(self.balanceOf[to], 1)

    self.ownerOf[id] = to

    self.get_approved[id] = empty(address)

    log Transfer(_from, to, id)

@external
def transferFrom(_from: address, to: address, id: uint256):
    """
        @param _from The address to transfer from
        @param to The address to transfer to
        @param id The token id to transfer
    """
    self.transfer_from(_from, to, id)

@external
def safeTransferFrom(_from: address, to: address, id: uint256, data: Bytes[1024] = b""):
    """
        @dev requires an ERC721Reciever implementation at the to address
        @param _from The address to transfer from
        @param to The address to transfer to
        @param id The token id to transfer
        @param data Additional data for the callback
    """
    self.transfer_from(_from, to, id)

    assert to.codesize == 0 or ERC721Reciever(to).onERC721Received(msg.sender, _from, id, data) == method_id("onERC721Received(address,address,uint256,bytes)", output_type=bytes4), "TRANSFER_REJECTED"

@external
@view
def tokenURI(token_id: uint256) -> String[512]:
    return concat("https://droplet.wtf/droplets/", uint2str(token_id), ".json")

################################################################
#                            ERC165                            #
################################################################
_SUPPORTED_INTERFACES: constant(bytes4[4]) = [
    0x01FFC9A7, # The ERC-165 identifier for ERC-165.
    0x80AC58CD, # The ERC-165 identifier for ERC-721.
    0x5B5E139F,  # The ERC-165 identifier for ERC-721 Metadata.
    0x780E9D63 # The ERC-165 identifier for the ERC-721 enumeration extension.
]

@external
def supportsInterface(interfaceID: bytes4) -> bool:
    return interfaceID in _SUPPORTED_INTERFACES

################################################################
#                          MINT/BURN                           #
################################################################
@external
def set_minter(new_minter: address, toggle: bool):
    """
        @param new_minter The address to be added/removed as a minter
        @param toggle The toggle for adding/removing the minter
    """
    assert msg.sender == self.owner, "NOT OWNER"
    self.minters[new_minter] = toggle

@external
def mint(to: address) -> uint256:
    """
        @param to The address to mint the token to
    """
    return self._mint(to)

@internal
def _mint(to: address) -> uint256:
    """
        @param to The address to mint the token to
    """
    assert self.minters[msg.sender], "NOT AUTHORIZED"
    assert to != empty(address), "INVALID_RECIPIENT"
    _totalSupply: uint256 = self.totalSupply
    new_id: uint256 = unsafe_add(_totalSupply, 1)
    self.totalSupply = new_id

    self.balanceOf[to] = unsafe_add(self.balanceOf[to], 1)
    self.ownerOf[new_id] = to

    DRIP(self.drip).init_id(new_id)

    log Transfer(empty(address), to, new_id)

    return new_id

