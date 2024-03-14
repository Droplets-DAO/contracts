# @version 0.3.10

"""
@title DRIP Token
@author CopyPaste
@license GNU Affero General Public License v3.0
"""

from vyper.interfaces import ERC721

interface BLAST:
    def configureClaimableGas(): nonpayable
    def configureClaimableYield(): nonpayable
    def claimAllYield(contractAddress: address, recipientOfYield: address) -> uint256: nonpayable
    def claimAllGas(contractAddress: address, recipientOfGas: address) -> uint256: nonpayable
    
interface IBLASTPointsOperator:
    def configurePointsOperator(op: address): nonpayable

interface Droplet:
    def totalSupply() -> uint256: view

################################################################
#                            EVENTS                            #
################################################################

event Transfer:
    owner: indexed(address)
    to: indexed(address)
    amount: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    amount: uint256

################################################################
#                           STORAGE                            #
################################################################

name: public(immutable(String[64]))
symbol: public(immutable(String[5]))
decimals: public(constant(uint256)) = 18

totalSupply: public(uint256)

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])

################################################################
#                       TOKENOMICS MATH                        #
################################################################

# Amount of Drip an NFT would have accumulated from Day One
GLOBAL_SUMMATION: public(uint256)
# Tracks tokenId to Drip claimed
total_claimed: public(HashMap[uint256, uint256])

################################################################
#                         CONSTRUCTOR                          #
################################################################

droplet_nft: public(immutable(address))
fee_controller: public(immutable(address))

@external
def __init__(droplet_nft_address: address):
  name = "Drip Token"
  symbol = "DRIP"
  droplet_nft = droplet_nft_address

  BLAST(0x4300000000000000000000000000000000000002).configureClaimableGas()
  BLAST(0x4300000000000000000000000000000000000002).configureClaimableYield()

  IBLASTPointsOperator(0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800).configurePointsOperator(msg.sender)

  fee_controller = msg.sender

@external
def change_fee_controller(new_controller: address):
    assert msg.sender == fee_controller, "NOT OWNER"
    fee_controller = new_controller

@external
def claim_money(account: address):
    assert msg.sender == fee_controller, "NOT OWNER"

    BLAST(0x4300000000000000000000000000000000000002).claimAllYield(self, account)
    BLAST(0x4300000000000000000000000000000000000002).claimAllGas(self, account)

################################################################
#                   ERC20 STANDARD FUNCTIONS                   #
################################################################

@external
def approve(spender: address, amount: uint256) -> bool:
  """
    @param spender The approved spender of the tokens
    @param amount The amount of tokens the spender is approved to spend
  """
  self.allowance[msg.sender][spender] = amount

  log Approval(msg.sender, spender, amount)

  return True

@external
def transfer(to: address, amount: uint256) -> bool:
  """
    @param to The recipient of the tokens
    @param amount The amount of tokens to transfer

    @return Success of the transfer
  """
  self.balanceOf[msg.sender] -= amount

  self.balanceOf[to] = unsafe_add(self.balanceOf[to], amount)

  log Transfer(msg.sender, to, amount)

  return True

@external
def transferFrom(_from: address, to: address, amount: uint256) -> bool:
  """
    @param _from From whom to transfer the tokens
    @param to The recipient of the tokens
    @param amount The amount of tokens to transfer

    @return Success of the transfer
  """
  allowed: uint256 = self.allowance[_from][msg.sender]
  if allowed != max_value(uint256):
    self.allowance[_from][msg.sender] = allowed - amount

  self.balanceOf[_from] -= amount
  self.balanceOf[to] = unsafe_add(self.balanceOf[to], amount)

  log Transfer(_from, to, amount)

  return True

################################################################
#                          EMISSIONS                           #
################################################################

@external
def init_id(tokenId: uint256):
  assert msg.sender == droplet_nft, "Only Droplet can init nfts"
  sum: uint256 = self.GLOBAL_SUMMATION

  sum += (96 * 10 ** 18) / Droplet(droplet_nft).totalSupply()

  self.total_claimed[tokenId] = sum
  self.GLOBAL_SUMMATION = sum

@view
@external
def preview_mint(id: uint256) -> uint256:
  """
    @notice Preview the amount of tokens that can be minted
    @return The amount of tokens that can be minted
  """
  total_claimed: uint256 = self.total_claimed[id]
  assert total_claimed != 0, "Token not initialized"

  sum: uint256 = self.GLOBAL_SUMMATION
  amount_owed: uint256 = sum - total_claimed

  return amount_owed


@external
def mint(id: uint256, to: address) -> uint256:
  """
    @notice Mint new tokens
    @param to The address to mint the tokens to
  """
  assert msg.sender == ERC721(droplet_nft).ownerOf(id), "Only the owner of the NFT can mint"
  total_claimed: uint256 = self.total_claimed[id]
  assert total_claimed != 0, "Token not initialized"

  sum: uint256 = self.GLOBAL_SUMMATION
  amount_owed: uint256 = sum - total_claimed
  self.total_claimed[id] = sum

  self.balanceOf[to] = unsafe_add(self.balanceOf[to], amount_owed)
  self.totalSupply = unsafe_add(self.totalSupply, amount_owed)

  log Transfer(empty(address), to, amount_owed)

  return amount_owed