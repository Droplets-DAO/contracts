# @version 0.3.10

"""
@title DRIP Token
@author CopyPaste
@license GNU Affero General Public License v3.0
"""

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
nonces: public(HashMap[address, uint256])

################################################################
#                         CONSTRUCTOR                          #
################################################################

@external
def __init__():
  name = "DRIP Token"
  symbol = "DRIP"
  DOMAIN_SEPARATOR = keccak256(_abi_encode("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)", keccak256("DRIP Token"), keccak256("1"), chain.id, self))

# @dev Constant used as part of the ECDSA recovery function.
_MALLEABILITY_THRESHOLD: constant(bytes32) = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
_TYPE_HASH: constant(bytes32) = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
_PERMIT_TYPE_HASH: constant(bytes32) = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
DOMAIN_SEPARATOR: public(immutable(bytes32))

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
  allowed: uint256 = self.allowance[msg.sender][_from]
  if allowed != max_value(uint256):
    self.allowance[msg.sender][_from] = allowed - amount

  self.balanceOf[_from] -= amount
  self.balanceOf[to] = unsafe_add(self.balanceOf[to], amount)

  log Transfer(_from, to, amount)

  return True

################################################################
#                           EIP-2612                           #
################################################################

@external
def permit(owner: address, spender: address, amount: uint256, deadline: uint256, v: uint8, r: bytes32, s: bytes32):
  assert block.timestamp <= deadline, "ERC20Permit: expired deadline"

  current_nonce: uint256 = self.nonces[owner]
  self.nonces[owner] = unsafe_add(current_nonce, 1)

  struct_hash: bytes32 = keccak256(_abi_encode(_PERMIT_TYPE_HASH, owner, spender, amount, current_nonce, deadline))
  hash: bytes32 = keccak256(concat(b"\x19\x01", DOMAIN_SEPARATOR, struct_hash))

  assert convert(s, uint256) <= convert(_MALLEABILITY_THRESHOLD, uint256), "ECDSA: invalid signature `s` value"

  signer: address = ecrecover(hash, v, r, s)
  assert signer != empty(address), "ECDSA: invalid signature"
  assert signer == owner, "ERC20Permit: invalid signature"

  self.allowance[owner][spender] = amount
  log Approval(owner, spender, amount)
