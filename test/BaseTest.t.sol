pragma solidity 0.8.20;

import "forge-std/Test.sol";

import {dEth} from "src/deth/dEth.sol";
import {wLST} from "src/deth/wLST.sol";

contract BaseTest is Test {
  
  wLST public baseWrapper;
  dEth public deth;
  
  uint256 mainnetFork;

  address public WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

  address public USER1 = address(1);
  address public USER2 = address(2);
  address public USER3 = address(3);
  address public USER4 = address(4);
  address public USER5 = address(5);


  function setUp() external {
    mainnetFork = vm.createFork("https://eth.llamarpc.com");

    baseWrapper = new wLST();

    // Approve specific LSTs for testing
    baseWrapper.allowlistLST(WSTETH);

    deth = new dEth(baseWrapper);
  }

  modifier mainnetTest {
    vm.selectFork(mainnetFork);
    _;
  }

  function testDeposit() mainnetTest public {
    vm.deal(USER1, 10 ether);
  }

}
