/// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";

import { DropletNFT } from "src/faucet/DropletToken.sol";
import { DropletFaucet } from "src/faucet/DropletFaucet.sol";

import { MockERC20 } from "./mocks/MockERC20.sol";

contract AuctionTest is Test {
    DropletNFT nft;
    DropletFaucet faucet;

    MockERC20 token;
    
    function setUp() public {
        token = new MockERC20();

        nft = new DropletNFT();
        faucet = new DropletFaucet(address(nft), address(token));
        nft.transferOwnership(address(faucet));
    }

    function testCreateAuction() public {
        // Destructuring is my passion
        (uint256 dropletId, uint256 amount, uint256 starttime, uint256 endTime, address payable bidder, bool settled) = faucet.auction();
        assertEq(dropletId, 0);
        assertEq(amount, 0);
        assertEq(starttime, 0);
        assertEq(endTime, 0);
        assertEq(bidder, payable(0));
        assertEq(settled, false);

        faucet.startNextAuction();

        (dropletId, amount, starttime, endTime, bidder, settled) = faucet.auction();

        assertEq(dropletId, 1);
        assertEq(amount, 0);
        assertEq(starttime, block.timestamp);
        assertEq(endTime, block.timestamp + 1 days);
        assertEq(bidder, payable(0));
        assertEq(settled, false);
    }

    function testBid() public {
        faucet.startNextAuction();

        (uint256 dropletId, uint256 amount, uint256 starttime, uint256 endTime, address payable bidder, bool settled) = faucet.auction();
        assertEq(dropletId, 1);
        assertEq(amount, 0);
        assertEq(starttime, block.timestamp);
        assertEq(endTime, block.timestamp + 1 days);
        assertEq(bidder, payable(0));
        assertEq(settled, false);

        vm.deal(address(0x6), 2 ether);
        vm.prank(address(0x6));
        faucet.createBid{value: 1 ether}(1);

        (dropletId, amount, starttime, endTime, bidder, settled) = faucet.auction();
        assertEq(dropletId, 1);
        assertEq(amount, 1 ether);
        assertEq(starttime, block.timestamp);
        assertEq(endTime, block.timestamp + 1 days);
        assertEq(bidder, payable(address(0x6)));
        assertEq(settled, false);

        vm.deal(address(0x7), 2 ether);
        vm.prank(address(0x7));
        faucet.createBid{value: 2 ether}(1);

        (dropletId, amount, starttime, endTime, bidder, settled) = faucet.auction();
        assertEq(dropletId, 1);
        assertEq(amount, 2 ether);
        assertEq(starttime, block.timestamp);
        assertEq(endTime, block.timestamp + 1 days);
        assertEq(bidder, payable(address(0x7)));
        assertEq(settled, false);
    }

    function testRejectsInsufficientlyHighBid() public {
        faucet.startNextAuction();

        vm.deal(address(0x6), 1 ether);
        vm.prank(address(0x6));
        faucet.createBid{value: 1 ether}(1);

        vm.deal(address(0x7), 2 ether);
        vm.prank(address(0x7));
        vm.expectRevert("DropletFaucet: Bid too low");
        faucet.createBid{value: 1.04 ether}(1);
    }

    function testRejectsTooBidLate() public {
        faucet.startNextAuction();

        vm.deal(address(0x6), 1 ether);
        vm.prank(address(0x6));
        faucet.createBid{value: 1 ether}(1);

        vm.warp(86401);

        vm.deal(address(0x7), 2 ether);
        vm.prank(address(0x7));
        vm.expectRevert("DropletFaucet: Auction has ended");
        faucet.createBid{value: 2 ether}(1);
    }

    function testJITBidExtendsAuction() public {
        faucet.startNextAuction();

        vm.deal(address(0x6), 1 ether);
        vm.prank(address(0x6));
        faucet.createBid{value: 1 ether}(1);

        uint256 startTime = block.timestamp;
        assertEq(startTime, 1);

        vm.warp(86399);

        vm.deal(address(0x7), 2 ether);
        vm.prank(address(0x7));
        faucet.createBid{value: 2 ether}(1);

        (uint256 dropletId, uint256 amount, uint256 starttime, uint256 endTime, address payable bidder, bool settled) = faucet.auction();
        assertEq(dropletId, 1);
        assertEq(amount, 2 ether);
        assertEq(starttime, 1);
        assertEq(endTime, 1 + 1 days + 5 minutes);
        assertEq(bidder, payable(address(0x7)));
        assertEq(settled, false);
    }
}