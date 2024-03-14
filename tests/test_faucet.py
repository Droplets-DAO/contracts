import boa
import pytest
from hypothesis import (
    given,
    settings,
    strategies as st,
)

def test_nft_mint(droplet_nft, admin, drip, accounts):
    """
        Test the mint function of the droplet_nft with reverts and auth checks
    """
    droplet_nft.init_drip(drip, sender=admin)
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
    droplet_nft.init_drip(drip, sender=admin)

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

    admin_bal = boa.env.get_balance(admin)

    faucet.bid(1, value=(4* 10 ** 18), sender=admin)

    assert admin_bal - 4 * 10 ** 18 == boa.env.get_balance(admin)

    faucet.bid(1, value=(5* 10 ** 18), sender=accounts[0])

    assert admin_bal == boa.env.get_balance(admin)

    (droplet_id, amount, start_time, d_end_time, bidder, settled) = faucet.auction()
    assert d_end_time - end_time == (60 * 5)

    boa.env.time_travel(7 * 50)

    faucet.settle_auction(sender=admin)

    assert droplet_nft.ownerOf(1) == accounts[0]

    with boa.reverts("DropletFaucet: Auction already settled"):
        faucet.settle_auction(sender=admin)

def test_start_after_free_flow(mock_drip, drip, droplet_nft, mock_faucet, admin, accounts):
    """
        Test a basic auction scenario
    """
    droplet_nft.init_drip(drip, sender=admin)
    faucet = mock_faucet
    genesis = faucet.GENESIS()
    free_flow = faucet.FREE_FLOW_DURATION()

    time = boa.env.vm.patch.timestamp
    boa.env.time_travel(((genesis + free_flow) - 86405) - time)

    faucet.start_next_auction(sender=accounts[5])
    boa.env.set_balance(admin, 1000 * 10 ** 18)
    faucet.bid(droplet_nft.totalSupply(), value=(1* 10 ** 18), sender=admin)
    time = boa.env.vm.patch.timestamp
    boa.env.time_travel(86401)
    faucet.settle_auction(sender=admin)

    assert faucet.last_settled_auction() == boa.env.vm.patch.timestamp

    assert genesis + free_flow > boa.env.vm.patch.timestamp

    mock_drip.mint(admin, 1000 * 10 ** 18, sender=admin)

    with boa.env.anchor():
        boa.env.time_travel(86400 * 3 + 1000)
        assert genesis + free_flow < boa.env.vm.patch.timestamp
        mock_drip.approve(faucet.address, 96 * 10 ** 18, sender=admin)
        initial_balance = mock_drip.balanceOf(admin)
        faucet.start_next_auction(sender=admin)
        assert mock_drip.balanceOf(admin) == initial_balance - 96 * 10 ** 18

    with boa.env.anchor():
        boa.env.time_travel(86400 * 5 + 1000)
        assert genesis + free_flow < boa.env.vm.patch.timestamp
        mock_drip.approve(faucet.address, 48 * 10 ** 18, sender=admin)
        initial_balance = mock_drip.balanceOf(admin)
        faucet.start_next_auction(sender=admin)
        assert mock_drip.balanceOf(admin) == initial_balance - 48 * 10 ** 18

    with boa.env.anchor():
        boa.env.time_travel(86400 * 7 + 1000)
        assert genesis + free_flow < boa.env.vm.patch.timestamp
        mock_drip.approve(faucet.address, 12 * 10 ** 18, sender=admin)
        initial_balance = mock_drip.balanceOf(admin)
        faucet.start_next_auction(sender=admin)
        assert mock_drip.balanceOf(admin) == initial_balance - 12 * 10 ** 18

    with boa.env.anchor():
        boa.env.time_travel(86400 * 10 + 1000)
        assert genesis + free_flow < boa.env.vm.patch.timestamp
        faucet.start_next_auction(sender=admin)


    with boa.env.anchor():
        boa.env.time_travel(86400 * 15 + 1000)
        assert genesis + free_flow < boa.env.vm.patch.timestamp
        faucet.start_next_auction(sender=admin)

