import boa
import pytest
from hypothesis import (
    given,
    settings,
    strategies as st,
)

def test_nft_mint(droplet_nft, admin, accounts):
    """
        Test the mint function of the droplet_nft with reverts and auth checks
    """
    assert droplet_nft.totalSupply() == 0

    with boa.env.prank(admin):
        droplet_nft.mint(admin)

    assert droplet_nft.ownerOf(1) == admin
    assert droplet_nft.totalSupply() == 1

    with boa.reverts("NOT AUTHORIZED"):
        droplet_nft.mint(admin, sender=accounts[0])
    
    with boa.reverts("INVALID_RECIPIENT"):
        droplet_nft.mint("0x0000000000000000000000000000000000000000", sender=admin)

    with boa.env.prank(admin):
        droplet_nft.mint(accounts[3])

    assert droplet_nft.ownerOf(2) == accounts[3]
    assert droplet_nft.totalSupply() == 2

def test_faucet(droplet_nft, drip, faucet, admin, accounts):
    """
        Test a basic auction scenario
    """

    assert faucet.drip_token() == drip.address
    assert faucet.droplet() == droplet_nft.address

    faucet.start_next_auction(sender=accounts[5])

    (droplet_id, amount, start_time, end_time, bidder, settled) = faucet.auction()

    assert droplet_id == 1
    assert amount == 0
    assert start_time == boa.env.vm.patch.timestamp
    assert end_time == start_time + 86400
    assert bidder == "0x0000000000000000000000000000000000000000"
    assert settled == False

    assert droplet_nft.ownerOf(1) == faucet.address

    boa.env.set_balance(admin, 1000 * 10 ** 18)
    boa.env.set_balance(accounts[0], 1000 * 10 ** 18)

    faucet.bid(1, value=(1* 10 ** 18), sender=admin)
    (droplet_id, amount, start_time, end_time, bidder, settled) = faucet.auction()
    assert amount == 1 * 10 ** 18
    assert bidder == admin

    faucet.bid(1, value=(2* 10 ** 18), sender=accounts[0])
    (droplet_id, amount, start_time, end_time, bidder, settled) = faucet.auction()
    assert amount == 2 * 10 ** 18
    assert bidder == accounts[0]

    assert boa.env.get_balance(faucet.address) == 2 * 10 ** 18
    # Funds should be returned
    assert boa.env.get_balance(admin) == 1000 * 10 ** 18

    with boa.reverts("DropletFaucet: Auction has not ended"):
        faucet.settle_auction(sender=admin)

    boa.env.time_travel(86399)

    faucet.bid(1, value=(4* 10 ** 18), sender=admin)

    faucet.bid(1, value=(5* 10 ** 18), sender=accounts[0])
    (droplet_id, amount, start_time, d_end_time, bidder, settled) = faucet.auction()
    assert d_end_time - end_time == (60 * 5)

    boa.env.time_travel(7 * 50)

    faucet.settle_auction(sender=admin)

    assert droplet_nft.ownerOf(1) == accounts[0]

    with boa.reverts("DropletFaucet: Auction already settled"):
        faucet.settle_auction(sender=admin)

def test_start_after_free_flow(mock_drip, mock_faucet, admin, accounts):
    """
        Test a basic auction scenario
    """

    faucet = mock_faucet
    boa.env.set_balance(admin, 1000 * 10 ** 18)
    genesis = faucet.GENESIS()
    free_flow = faucet.FREE_FLOW_DURATION()

    boa.env.time_travel(genesis + free_flow + 1)
    faucet.start_next_auction(sender=admin)
    faucet.bid(1, value=(1* 10 ** 18), sender=admin)
    boa.env.time_travel(86401)
    faucet.settle_auction(sender=admin)

    with boa.reverts("Faucet is on cooldown"):
        faucet.start_next_auction(sender=admin)

    boa.env.time_travel((86400 * 3) + 100)
    mock_drip.mint(admin, 1000 * 10 ** 18, sender=admin)
    mock_drip.approve(faucet.address, 1000 * 10 ** 18, sender=admin)
    faucet.start_next_auction(sender=admin)
    faucet.bid(2, value=(1* 10 ** 18), sender=admin)
    boa.env.time_travel(86401)
    faucet.settle_auction(sender=admin)