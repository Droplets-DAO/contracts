import boa
import pytest
from hypothesis import (
    given,
    settings,
    strategies as st,
)

boa.env.fork(url="https://arb-mainnet.g.alchemy.com/v2/hqzk9z72_BWmDMRw6u2lMOCbEXy7Rj6A")

def test_deploy_stream(admin, accounts, droplet_nft):    
    # Arb addresses
    XY_CURVE = "0x31F85DDAB4b77a553D2D4aF38bbA3e3CB7E425c9"
    FACTORY = "0x4f1627be4C72aEB9565D4c751550C4D262a96B51"
    NFT = droplet_nft.address
    PROPERTY_CHECKER = "0x0000000000000000000000000000000000000000"
    DELTA = 1040000000000000000 # 2% Delta
    FEE = 70000000000000000 # 7%
    SPOT_PRICE = 908916953693073096

    with boa.env.prank(admin):
        stream = boa.load('src/stream.vy', FACTORY, NFT, XY_CURVE, DELTA, FEE, SPOT_PRICE, PROPERTY_CHECKER)
