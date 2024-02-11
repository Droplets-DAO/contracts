/// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

interface IStream {
    struct Bond {
        address owner;
        uint256 maturity;
        uint256 price;
        uint256 fee_snapshot;
    }

    function bond_nft(uint256 id) external returns (uint256);
    function redeem_bond(uint256 bond_id, uint256 id) external;
    function bonded_nft() external view returns (address);
    function factory() external view returns (address);
    function pair() external view returns (address);
    function ether_funded() external view returns (uint256);
    function bonds_issued() external view returns (uint256);
    function nft_bonds(uint256 arg0) external view returns (uint256);
    function fees_earned() external view returns (uint256);
}
