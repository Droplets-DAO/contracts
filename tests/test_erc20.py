import boa
import pytest
from hypothesis import (
    given,
    settings,
    strategies as st,
)


def _mint_tokens(droplet_nft, drip, admin):
    droplet_nft.init_drip(drip, sender=admin)
    id = droplet_nft.mint(admin, sender=admin)
    id2 = droplet_nft.mint(admin, sender=admin)
    id3 = droplet_nft.mint(admin, sender=admin)

    with boa.env.prank(droplet_nft.address):
        drip.init_id(id)
        drip.init_id(id2)
        drip.init_id(id3)

    boa.env.time_travel(86400)

    return drip.mint(id, admin, sender=admin) 

def test_metadata(drip):
    assert drip.name() == "Drip Token"
    assert drip.symbol() == "DRIP"
    assert drip.decimals() == 18

def test_mint(droplet_nft, drip, admin):
    _mint_tokens(droplet_nft, drip, admin)
    assert droplet_nft.ownerOf(1) == admin
    assert drip.balanceOf(admin) > 10 * 10 ** 18

def test_transfer(droplet_nft, drip, admin, accounts):
    amount = _mint_tokens(droplet_nft, drip, admin)
    balance = drip.balanceOf(admin)

    drip.transfer(accounts[0], balance, sender=admin)

    assert drip.balanceOf(admin) == 0
    assert drip.balanceOf(accounts[0]) == balance

def test_approve(droplet_nft, drip, admin, accounts):
    _mint_tokens(droplet_nft, drip, admin)

    balance = drip.balanceOf(admin)
    drip.approve(accounts[0], balance, sender=admin)

    assert drip.allowance(admin, accounts[0]) == balance

def test_transferFrom(droplet_nft, drip, admin, accounts):
    _mint_tokens(droplet_nft, drip, admin)

    balance = drip.balanceOf(admin)

    with boa.reverts():
        drip.transferFrom(admin, accounts[1], balance, sender=accounts[0])

    drip.approve(accounts[0], balance, sender=admin)

    assert drip.allowance(admin, accounts[0]) == balance

    drip.transferFrom(admin, accounts[1], balance, sender=accounts[0])

    assert drip.balanceOf(admin) == 0
    assert drip.balanceOf(accounts[1]) == balance

def test_tokens_are_minted_as_expected(droplet_nft, drip, admin):
    droplet_nft.init_drip(drip, sender=admin)
    id = droplet_nft.mint(admin, sender=admin)
    id2 = droplet_nft.mint(admin, sender=admin)
    id3 = droplet_nft.mint(admin, sender=admin)

    with boa.env.prank(droplet_nft.address):
        drip.init_id(id)
        drip.init_id(id2)
        drip.init_id(id3)

    boa.env.time_travel(86400)
    
    assert drip.mint(id, admin, sender=admin) == (96 * 10 ** 18) / (droplet_nft.totalSupply()-1)
    assert drip.mint(id2, admin, sender=admin) == (96 * 10 ** 18) / (droplet_nft.totalSupply()-1)
    assert drip.mint(id3, admin, sender=admin) == (96 * 10 ** 18) / (droplet_nft.totalSupply()-1)

    boa.env.time_travel(86400 * 2)

    assert drip.mint(id, admin, sender=admin) == ((96 * 10 ** 18) / (droplet_nft.totalSupply()-1)) + ((96 * 10 ** 18) / (droplet_nft.totalSupply()-2))

    boa.env.time_travel(86400 / 2)

    assert drip.mint(id, admin, sender=admin) == 24000000000000000000