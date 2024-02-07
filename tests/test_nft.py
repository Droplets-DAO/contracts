import boa
import pytest
from hypothesis import (
    given,
    settings,
    strategies as st,
)

def test_minters(admin, accounts, droplet_nft):
    assert droplet_nft.minters(admin)

    id = droplet_nft.mint(accounts[0], sender=admin)
    assert droplet_nft.ownerOf(id) == accounts[0]

    with boa.reverts("NOT AUTHORIZED"):
        droplet_nft.mint(accounts[1], sender=accounts[0])

    with boa.reverts("INVALID_RECIPIENT"):
        droplet_nft.mint("0x0000000000000000000000000000000000000000", sender=admin)

    id2 = droplet_nft.mint(accounts[2], sender=admin)
    assert (id + 1) == id2
    assert droplet_nft.ownerOf(id2) == accounts[2]

def test_transfer(admin, accounts, droplet_nft):
    id = droplet_nft.mint(accounts[0], sender=admin)
    assert droplet_nft.ownerOf(id) == accounts[0]

    droplet_nft.approve(accounts[1], id, sender=accounts[0])
    droplet_nft.transferFrom(accounts[0], accounts[2], id, sender=accounts[1])

    assert droplet_nft.ownerOf(id) == accounts[2]

    with boa.reverts("WRONG_FROM"):
        droplet_nft.transferFrom(accounts[3], accounts[4], id, sender=accounts[1])

    with boa.reverts("Not Authorized"):
        droplet_nft.transferFrom(accounts[2], accounts[3], id, sender=accounts[1])

    with boa.reverts("INVALID_RECIPIENT"):
        droplet_nft.transferFrom(accounts[2], "0x0000000000000000000000000000000000000000", id, sender=accounts[0])

def test_approvals(admin, accounts, droplet_nft):
    id = droplet_nft.mint(accounts[0], sender=admin)
    assert droplet_nft.ownerOf(id) == accounts[0]

    droplet_nft.approve(accounts[1], id, sender=accounts[0])
    assert droplet_nft.get_approved(id) == accounts[1]

    droplet_nft.setApprovalForAll(accounts[1], True, sender=accounts[0])
    assert droplet_nft.isApprovedForAll(accounts[0], accounts[1])

    droplet_nft.setApprovalForAll(accounts[1], False, sender=accounts[0])
    assert not droplet_nft.isApprovedForAll(accounts[0], accounts[1])

    with boa.reverts("NOT_AUTHORIZED"):
        droplet_nft.approve(accounts[2], id, sender=accounts[1])