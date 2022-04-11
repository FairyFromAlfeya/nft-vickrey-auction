// contracts/NFTVickreyAuction.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/INFTVickreyAuction.sol";
import "./security/TimeGuard.sol";

contract NFTVickreyAuction is Ownable, INFTVickreyAuction, TimeGuard {
    constructor(uint _startAt, uint _finishAt) TimeGuard(_startAt, _finishAt) {}
}
