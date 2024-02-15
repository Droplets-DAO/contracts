import boa
import pytest
from hypothesis import (
    given,
    settings,
    strategies as st,
)

def test_sudo_setup(lssvm_factory):
    return

def test_deploy_stream(admin, droplet_nft, drip, lssvm_factory, lssvm_XykCurve):    
    droplet_nft.init_drip(drip, sender=admin)

    # Arb addresses
    XY_CURVE = lssvm_XykCurve
    FACTORY = lssvm_factory
    NFT = droplet_nft.address
    PROPERTY_CHECKER = "0x0000000000000000000000000000000000000000"
    DELTA = 1040000000000000000 # 2% Delta
    FEE = 70000000000000000 # 7%
    SPOT_PRICE = 908916953693073096

    with boa.env.prank(admin):
        stream = boa.load('src/stream.vy', FACTORY, NFT, XY_CURVE, DELTA, FEE, SPOT_PRICE, PROPERTY_CHECKER)

    id = droplet_nft.mint(admin, sender=admin)
    droplet_nft.setApprovalForAll(stream.address, True, sender=admin)
    #stream.bond_nft(id, sender=admin)
