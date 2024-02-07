from math import log
from typing import Any, Callable, List

import boa
import pytest
from hypothesis import settings


@pytest.fixture(scope="session")
def accounts() -> List[Any]:
    return [boa.env.generate_address() for _ in range(11)]

@pytest.fixture(scope="session")
def admin(accounts) -> Any:
    return boa.env.generate_address()

@pytest.fixture(scope="session")
def blast(admin):
    with boa.env.prank(admin):
        blast = boa.load_partial('tests/mocks/blast.vy')
        #boa.env.vm.state.set_code("0x4300000000000000000000000000000000000002", blast)
        return blast
    
@pytest.fixture(scope="session")
def drip(admin):
    with boa.env.prank(admin):
        return boa.load('src/drip.vy')
    
@pytest.fixture(scope="session")
def droplet_nft(admin):
    with boa.env.prank(admin):
        return boa.load('src/droplet_nft.vy')

@pytest.fixture(scope="session")
def faucet(admin, drip, blast, droplet_nft):
    with boa.env.prank(admin):
        faucet = boa.load('src/droplet_faucet.vy', droplet_nft.address, drip.address, admin)
        droplet_nft.set_minter(faucet.address, True, sender=admin)
        return faucet

@pytest.fixture(scope="session")
def mock_drip(admin):
    with boa.env.prank(admin):
        return boa.load('tests/mocks/mock_erc20.vy', "Mock DRIP", "DRIP", 18)

@pytest.fixture(scope="session")
def mock_faucet(admin, mock_drip, blast, droplet_nft):
    with boa.env.prank(admin):
        faucet = boa.load('src/droplet_faucet.vy', droplet_nft.address, mock_drip.address, admin)
        droplet_nft.set_minter(faucet.address, True, sender=admin)
        return faucet
