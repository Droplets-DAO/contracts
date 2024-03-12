from math import log
from typing import Any, Callable, List

import boa
import pytest
from hypothesis import settings

boa.env.vm.patch.code_size_limit = 99999999999

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
        blast.at("0x4300000000000000000000000000000000000002")
        blast.at("0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800")
        return blast
    
@pytest.fixture(scope="session")
def droplet_nft(admin, blast):
    with boa.env.prank(admin):
        return boa.load('src/droplet_nft.vy')

@pytest.fixture(scope="session")
def drip(admin, droplet_nft, blast):
    with boa.env.prank(admin):
        return boa.load('src/drip.vy', droplet_nft.address)

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
    
@pytest.fixture(scope="session")
def dagon(admin):
    with boa.env.prank(admin):
        return boa.load('dagon/Dagon.sol')
    
@pytest.fixture(scope="session")
def summoner(admin):
    with boa.env.prank(admin):
        return boa.load('dagon/Summoner.sol')

@pytest.fixture(scope="session")
def lssvm_royalty_registry(admin):
    with boa.env.prank(admin):
        registry = boa.load_partial('lssvm2/RoyaltyRegistry.sol', contract_name='RoyaltyRegistry').deploy()
        registry.__init__("0x0000000000000000000000000000000000000000")

        return registry
    
@pytest.fixture(scope="session")
def lssvm_royalty_engine(admin, lssvm_royalty_registry):
    with boa.env.prank(admin):
        engine = boa.load_partial('lssvm2/RoyaltyEngine.sol', contract_name='RoyaltyEngine').deploy()
        engine.__init__(lssvm_royalty_registry.address)

        return engine

@pytest.fixture(scope="session")
def lssvm_exponential_curve(admin):
    with boa.env.prank(admin):
        return boa.load_partial('lssvm2/ExponentialCurve.sol').deploy()
    
@pytest.fixture(scope="session")
def lssvm_gda_curve(admin):
    with boa.env.prank(admin):
        return boa.load_partial('lssvm2/GDACurve.sol').deploy()
    
@pytest.fixture(scope="session")
def lssvm_linear_curve(admin):
    with boa.env.prank(admin):
        return boa.load_partial('lssvm2/LinearCurve.sol').deploy()
    
@pytest.fixture(scope="session")
def lssvm_XykCurve(admin):
    with boa.env.prank(admin):
        return boa.load_partial('lssvm2/XykCurve.sol').deploy()

@pytest.fixture(scope="session")
def lssvm_erc721_erc20(admin, lssvm_royalty_engine):
    with boa.env.prank(admin):
        pair = boa.load_partial('lssvm2/LSSVMPairERC721ERC20.sol').deploy()
        pair.__init__(lssvm_royalty_engine)
        return pair
    
@pytest.fixture(scope="session")
def lssvm_erc721_eth(admin, lssvm_royalty_engine):
    with boa.env.prank(admin):
        pair = boa.load_partial('lssvm2/LSSVMPairERC721ETH.sol').deploy()
        pair.__init__(lssvm_royalty_engine)
        return pair
    
@pytest.fixture(scope="session")
def lssvm_erc1155_erc20(admin, lssvm_royalty_engine):
    with boa.env.prank(admin):
        pair = boa.load_partial('lssvm2/LSSVMPairERC1155ERC20.sol').deploy()
        pair.__init__(lssvm_royalty_engine)
        return pair
    
@pytest.fixture(scope="session")
def lssvm_erc1155_eth(admin, lssvm_royalty_engine):
    with boa.env.prank(admin):
        pair = boa.load_partial('lssvm2/LSSVMPairERC1155ETH.sol').deploy()
        pair.__init__(lssvm_royalty_engine)
        return pair
    
@pytest.fixture(scope="session")
def lssvm_factory(admin,lssvm_erc1155_erc20, lssvm_erc1155_eth, lssvm_erc721_erc20, lssvm_erc721_eth, lssvm_XykCurve):
    with boa.env.prank(admin):
        factory = boa.load_partial('lssvm2/LSSVMPairFactory.sol').deploy()
        factory.__init__(lssvm_erc721_eth, lssvm_erc721_erc20, lssvm_erc1155_eth, lssvm_erc1155_erc20, "0x0000000000000000000000000000000000000000", 0)
        
        factory.setBondingCurveAllowed(lssvm_XykCurve, True, sender=admin)
        return factory

@pytest.fixture(scope="session")
def stream(admin, droplet_nft, lssvm_factory, lssvm_XykCurve):
    # Arb addresses
    XY_CURVE = lssvm_XykCurve
    FACTORY = lssvm_factory
    NFT = droplet_nft.address
    PROPERTY_CHECKER = "0x0000000000000000000000000000000000000000"
    DELTA = 1040000000000000000 # 2% Delta
    FEE = 70000000000000000 # 7%
    SPOT_PRICE = 908916953693073096

    with boa.env.prank(admin):
        return boa.load('src/stream.vy', FACTORY, NFT, XY_CURVE, DELTA, FEE, SPOT_PRICE, PROPERTY_CHECKER)