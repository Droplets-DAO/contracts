pragma solidity 0.8.20;

// Auth Imports
import {Owned} from "lib/solmate/src/auth/Owned.sol";

// Token Imports
import {IERC20} from "src/interfaces/IERC20.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {IERC4626} from "src/interfaces/IERC4626.sol";

interface ConversionOracle {
  // Returns the price of the LST in terms if ETH, sclaed to 1 wad
  function price() external returns (uint256);
}

// This contract breaks ERC4626 in several places, which is why dEth works as an actual
// ERC4626 wrapper contract, this is merely a router to normalize each lst

contract wLST is ERC20, Owned {
  uint256 public constant WAD = 1e18;

  constructor() ERC20("LST Wrapper Token", "wLST", 18) Owned(msg.sender) {}

  /*//////////////////////////////////////////////////////////////
                               EVENTS
  //////////////////////////////////////////////////////////////*/
  event AddedLST(address indexed lst, address indexed oracle);

  event RemovedLST(address indexed lst);

  /*//////////////////////////////////////////////////////////////
                          LST CONTROLS
  //////////////////////////////////////////////////////////////*/
  // Specific LSTs which can be used to mint wLST
  address[] public allowedLSTs;

  // Tracks whether or not a specific LST is allowed to be minted
  mapping(address => bool) public whitelistedLSTs;

  // Provides an address for the source of truth of LSD to ETH
  mapping(address => address) public conversionRate;

  function allowlistLST(address lst, address sourceOfTruth) external onlyOwner {
    whitelistedLSTs[lst] = true;
    conversionRate[lst] = sourceOfTruth;
    allowedLSTs.push(lst);

    emit AddedLST(lst, sourceOfTruth);
  }

  function removeLST(address lst, uint8 index) external onlyOwner {
    require(allowedLSTs[index] == lst, "MISMATCH");

    delete whitelistedLSTs[lst];
    delete conversionRate[lst];

    delete allowedLSTs[index];

    // Bump each element in the array down 1 slot
    if (allowedLSTs[index+1] == address(0)) {
      return;
    } else {
      uint8 n = index;
      while (allowedLSTs[n+1] != address(0)) {
        allowedLSTs[n] = allowedLSTs[n+1];
        unchecked {
          n++;
        }
      }
    } 

    emit RemovedLST(lst);
  }

  /*//////////////////////////////////////////////////////////////
                             ETH HELD
  //////////////////////////////////////////////////////////////*/
  uint256 public cachedTotalAssets;
  uint256 public lastUpdated;

  mapping(address => uint256) public tokensOwned;

  function _updatedTotalAssets() internal {
    if (lastUpdated == block.timestamp && cachedTotalAssets != 0) {
      return;
    }

    uint256 totalEth = 0;

    for(uint256 index; index < allowedLSTs.length; index++) {
      address lst = allowedLSTs[index];
      
      uint256 price = ConversionOracle(conversionRate[lst]).price();
      uint256 currentTokenAmount = tokensOwned[lst];

      uint256 eth = (currentTokenAmount * price) / WAD; 
    
      totalEth += eth;
    }

    fraction.numerator = uint128(totalEth);
    lastUpdated = block.timestamp;
  }


  /*//////////////////////////////////////////////////////////////
                             SHARE MATH
  //////////////////////////////////////////////////////////////*/
  struct Fraction {
    // Safety: This value should never be updated without replacing it with totalAssets() first
    uint128 numerator;
    uint128 denominator;
  }

  Fraction public fraction;

  function convertToShares(uint256 assets) public returns (uint256 shares) {
    // So if there are no shares, then they will mint 1:1 with assets
    // Otherwise, shares will mint proportional to the amount of assets
    _updatedTotalAssets();
    if ((uint256(fraction.numerator) == 0) || (uint256(fraction.denominator) == 0)) {
      shares = assets;
    } else {
      shares = (assets * uint256(fraction.denominator)) / uint256(fraction.numerator);
    }
  }

  function convertToAssets(uint256 shares) public returns (uint256 assets) {
    // So if there are no shares, then they will mint 1:1 with assets
    // Otherwise, shares will mint proportional to the amount of assets
    _updatedTotalAssets();
    if (uint256(fraction.numerator) == 0 || uint256(fraction.denominator) == 0) {
        assets = shares;
    } else {
      assets = (shares * uint256(fraction.numerator)) / uint256(fraction.denominator);
    }
  }

  /*//////////////////////////////////////////////////////////////
                             YIELD FLOW
  //////////////////////////////////////////////////////////////*/

  function deposit(address lst, address reciever, uint256 amount) external {
    require(whitelistedLSTs[lst], "WHITELIST");

    uint256 shares = convertToShares(amount);

    IERC20(lst).transferFrom(msg.sender, address(this), amount);
    tokensOwned[lst] += amount; 

    fraction.numerator += uint128(amount);
    fraction.denominator += uint128(shares);

    _mint(reciever, shares);
  }

  function redeem(address lst, address reciever, uint256 shares) external {
    require(whitelistedLSTs[lst], "WHITELIST");
    
    uint256 assets = convertToAssets(shares);

    tokensOwned[lst] -= assets;

    fraction.numerator -= uint128(assets);
    fraction.denominator -= uint128(shares);

    _burn(msg.sender, shares);

    uint256 price = ConversionOracle(conversionRate[lst]).price();
    uint256 lstOwed = (assets * WAD) / price;
    IERC20(lst).transfer(reciever, lstOwed);
  }
}
