// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;


/// @title Interface for Inflator

import { Inflate } from '../libs/Inflate.sol';

interface IInflator {
    function puff(bytes memory source, uint256 destlen) external pure returns (Inflate.ErrorCode, bytes memory);
}