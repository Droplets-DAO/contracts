import boa
import pytest
from hypothesis import (
    given,
    settings,
    strategies as st,
)

def test_sudo_setup(lssvm_factory):
    return

def test_deploy_instant_bond(admin, droplet_nft, drip, stream):    
    droplet_nft.init_drip(drip, sender=admin)

    id = droplet_nft.mint(admin, sender=admin)
    droplet_nft.setApprovalForAll(stream.address, True, sender=admin)
    bond = stream.bond_nft(id, sender=admin)

    assert droplet_nft.ownerOf(id) != admin

    boa.env.time_travel(86400 * 1000)

    # No price change, so we should recieve NFT back
    stream.redeem_bond(id, bond, sender=admin)
    assert droplet_nft.ownerOf(id) == admin

def test_simple_bond_upward_sim(admin, accounts, droplet_nft, drip, stream):    
    droplet_nft.init_drip(drip, sender=admin)

    boa.env.set_balance(accounts[5], 1000 * 10 ** 18)

    id = droplet_nft.mint(admin, sender=admin)
    droplet_nft.setApprovalForAll(stream.address, True, sender=admin)
    bond = stream.bond_nft(id, sender=admin)

    assert droplet_nft.ownerOf(id) != admin

    fees_before = stream.fees_earned()

    stream.__default__(value=10 * 10 ** 18, sender=accounts[5])

    assert stream.fees_earned() == fees_before + 10 * 10 ** 18

    boa.env.time_travel(86400 * 1000)

    lssvm_erc721_eth = boa.load_partial('lssvm2/LSSVMPairERC721ETH.sol')
    pair = lssvm_erc721_eth.at(stream.pair())
    pair.swapTokenForSpecificNFTs([id], 10 * 10 ** 18, accounts[5], False, accounts[5], sender=accounts[5], value=10 * 10 ** 18)

    # Price increased, so we should recieve more Ether back
    stream.redeem_bond(id, bond, sender=admin)

    assert boa.env.get_balance(admin) > (stream.fees_earned() / 2)