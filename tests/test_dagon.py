import boa
import pytest
from hypothesis import (
    given,
    settings,
    strategies as st,
)

boa.env.fork(url="https://opt-mainnet.g.alchemy.com/v2/h6emmq6kC1M6yx7CrQEohQNm6svMt6i1")

DAGON = "0x0000000000001D4B1320bB3c47380a3D1C3A1A0C"
SUMMONER = "0xDDc31C0272a3c4696124C8df1bCf096090a168B4" 

def test_dagon_summon(admin, droplet_nft, drip):
    """
        Huge thanks z80 for letting this happen
    """
    return
    droplet_nft.init_drip(drip, sender=admin)
    summon = boa.load_partial("src/summoner.vy").at(SUMMONER)
    id = droplet_nft.mint(admin, sender=admin)

    boa.env.time_travel(86399 * 1000)

    drip.mint(id, admin, sender=admin)
    dao = summon.summonForToken(drip.address, 1, 1000, bytes.fromhex("1234567890adcdef12345678"), sender=admin)
