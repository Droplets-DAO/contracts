pragma solidity 0.8.20;

import {ERC721} from "lib/solmate/src/tokens/ERC721.sol";
import "interfaces/IStream.sol";
import "../../lib/utils/VyperDeployer.sol";
import { Test } from "forge-std/Test.sol";

contract testNFT is ERC721("TEST NFT", "TEST") {
    function tokenURI(uint256 id) public view override returns (string memory) {
        return "https://test.com/uri";
    }
}

contract StreamTest is Test {

    enum PoolType {
        TOKEN,
        NFT,
        TRADE
    }


    address constant FACTORY = 0x4f1627be4C72aEB9565D4c751550C4D262a96B51;
    address NFT;
    address constant CURVE = 0x31F85DDAB4b77a553D2D4aF38bbA3e3CB7E425c9; // x*y=k
    uint128 constant DELTA = 0;
    uint96 constant FEE = 0;
    uint128 constant SPOT_PRICE = 0;
    address constant PROPERTY_CHECKER = 0x31F85DDAB4b77a553D2D4aF38bbA3e3CB7E425c9;

    IStream stream;
    VyperDeployer vyperDeployer = new VyperDeployer();

    function setUp() public {
        NFT = address(new testNFT());
        stream = IStream(vyperDeployer.deployContract("stream", abi.encode(FACTORY, NFT, CURVE, DELTA, FEE, SPOT_PRICE, PROPERTY_CHECKER)));
    }

    function testStream() public {
        return;
    }
}