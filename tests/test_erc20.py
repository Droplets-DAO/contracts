import boa
import pytest
from hypothesis import (
    given,
    settings,
    strategies as st,
)


def _mint_tokens(droplet_nft, drip, admin, amount):
    droplet_nft.init_drip(drip, sender=admin)
    id = droplet_nft.mint(admin, sender=admin)
    
    boa.env.time_travel(86399 * amount)

    drip.mint(id, admin, sender=admin)

def test_metadata(drip):
    assert drip.name() == "Drip Token"
    assert drip.symbol() == "DRIP"
    assert drip.decimals() == 18

def test_mint(droplet_nft, drip, admin):
    _mint_tokens(droplet_nft, drip, admin, 1000)
    assert droplet_nft.ownerOf(1) == admin
    assert drip.balanceOf(admin) > 10 * 10 ** 18

def test_transfer(droplet_nft, drip, admin, accounts):
    _mint_tokens(droplet_nft, drip, admin, 1000)
    balance = drip.balanceOf(admin)

    drip.transfer(accounts[0], balance, sender=admin)

    assert drip.balanceOf(admin) == 0
    assert drip.balanceOf(accounts[0]) == balance

@given(
    amount=st.integers(min_value=100000, max_value=2**128-1),
)
@settings(max_examples=10, deadline=None)
def test_approve(droplet_nft, drip, admin, accounts, amount):
    _mint_tokens(droplet_nft, drip, admin, amount)

    balance = drip.balanceOf(admin)
    drip.approve(accounts[0], balance, sender=admin)

    assert drip.allowance(admin, accounts[0]) == balance


#@given(
#    amount=st.integers(min_value=100000, max_value=2**128-1),
#)
#@settings(max_examples=10, deadline=None)
def test_transferFrom(droplet_nft, drip, admin, accounts):
    amount = 10000
    _mint_tokens(droplet_nft, drip, admin, amount)

    balance = drip.balanceOf(admin)

    with boa.reverts():
        drip.transferFrom(admin, accounts[1], balance, sender=accounts[0])

    drip.approve(accounts[0], balance, sender=admin)

    assert drip.allowance(admin, accounts[0]) == balance

    drip.transferFrom(admin, accounts[1], balance, sender=accounts[0])

    assert drip.balanceOf(admin) == 0
    assert drip.balanceOf(accounts[1]) == balance