// contracts/security/TimeGuard.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/Timers.sol";

abstract contract TimeGuard {
    using Timers for Timers.Timestamp;
    using SafeCast for uint256;

    Timers.Timestamp public startAt;
    Timers.Timestamp public finishAt;

    constructor(uint _startAt, uint _finishAt) {
        require(_startAt > block.timestamp, "Start must be bigger than current timestamp");
        require(_startAt < _finishAt, "Start must be lower than finish");

        startAt = Timers.Timestamp(_startAt.toUint64());
        finishAt = Timers.Timestamp(_finishAt.toUint64());
    }

    modifier onlyBeforeStart() {
        require(startAt.isPending(), "Already started");
        _;
    }

    modifier onlyAfterStart() {
        require(startAt.isExpired(), "Not started");
        _;
    }

    modifier onlyBeforeFinish() {
        require(finishAt.isPending(), "Already finished");
        _;
    }

    modifier onlyAfterFinish() {
        require(finishAt.isExpired(), "Not finished");
        _;
    }
}
