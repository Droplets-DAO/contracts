pragma solidity 0.8.20;

// Token Imports
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {IERC4626} from "src/interfaces/IERC4626.sol";

// wLST is a neccessary sub-componet of dEth
import {wLST} from "src/deth/wLST.sol";

contract dEth is IERC4626, ERC20 {
  constructor(wLST _wrapper) ERC20("Droplet Staked Ether", "dsEth", 18) {
    wrapper = _wrapper;
  }

  wLST public immutable wrapper;

  /*//////////////////////////////////////////////////////////////
                              ERC4626
  //////////////////////////////////////////////////////////////*/
  function asset() external view returns (address) {
    return address(wrapper);
  }

  function totalAssets() external view returns (uint256) {
    // Technically wLST:dEth isn't implicitly 1:1 as someone could mint
    // wLST but never deposit it as dEth, so we have to be careful
    (uint256 numerator, uint256 denominator) = wrapper.fraction();
    uint256 ownedwLst= wrapper.balanceOf(address(this));
    
    // Should always be true, but added to make me sleep better
    require(denominator > ownedwLst, "INFLATION");
    return ownedwLst * numerator / denominator;
  }

  /*//////////////////////////////////////////////////////////////
                               EVENTS
  //////////////////////////////////////////////////////////////*/

  // Okokokok, so because we are just wrapping wLST to be ERC4626 compatible, we don't have a share/assets distinction
  // because we won't accumulate more wLST, as wLST will accumulate rewards for us
  function convertToShares(uint256 assets) pure public returns (uint256 shares) {
    return assets;
  }

  function convertToAssets(uint256 shares) pure public returns (uint256 assets) {
    return shares;
  }

  /*//////////////////////////////////////////////////////////////
                           MAX FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  function maxDeposit(address) external pure returns (uint256 maxAssets) {
    return type(uint256).max;
  }

  function maxMint(address) external pure returns (uint256 maxShares) {
    return type(uint256).max;
  }

  function maxWithdraw(address owner) external view returns (uint256 maxAssets) {
    // Shares are 1:1 with assets always in our case so this is ok
    return balanceOf[owner];
  }

  function maxRedeem(address owner) external view returns (uint256 maxShares) {
    // Shares are 1:1 with assets always in our case so this is ok
    return balanceOf[owner];
  }

  /*//////////////////////////////////////////////////////////////
                      PREVIEW FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  function previewMint(uint256 shares) external pure returns (uint256 assets) {
    assets = shares;
  }

  function previewRedeem(uint256 shares) external pure returns (uint256 assets) {
    assets = shares;
  }
  
  function previewDeposit(uint256 assets) external pure returns (uint256 shares) {
    shares = assets;
  }

  function previewWithdraw(uint256 assets) external pure returns (uint256 shares) {
    shares = assets;
  }

  /*//////////////////////////////////////////////////////////////
                          TOKEN FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  uint256 public wLSTDeposited;

  function deposit(uint256 assets, address receiver) external payable returns (uint256 shares) {
    wrapper.transferFrom(msg.sender, address(this), assets);
    
    wLSTDeposited += assets;
    _mint(receiver, assets);
  
    emit Deposit(msg.sender, receiver, assets, shares); 
  }

  function mint(uint256 shares, address receiver) external payable returns (uint256 assets) {
    wrapper.transferFrom(msg.sender, address(this), assets);

    wLSTDeposited += assets;
    _mint(receiver, assets);
    
    emit Deposit(msg.sender, receiver, assets, shares); 
  }

  function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets) {
    assets = shares;

    wLSTDeposited += assets;
    _burn(msg.sender, shares);
    
    wrapper.transfer(receiver, assets);
    emit Withdraw(msg.sender, receiver, owner, assets, shares);
  }

  function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares) {
    shares = assets;
    
    wLSTDeposited += assets;
    _burn(msg.sender, shares);


    wrapper.transfer(receiver, assets);
    emit Withdraw(msg.sender, receiver, owner, assets, shares);
  }
}
