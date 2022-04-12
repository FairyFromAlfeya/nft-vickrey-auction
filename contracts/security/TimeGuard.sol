// contracts/security/TimeGuard.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/Timers.sol";

abstract contract TimeGuard {
    using Timers for Timers.Timestamp;
    using SafeCast for uint256;

    error AlreadyStarted(uint64 startAt);
    error NotStarted(uint64 startAt);

    error AlreadyFinished(uint64 finishAt);
    error NotFinished(uint64 finishAt);

    Timers.Timestamp public startAt;
    Timers.Timestamp public finishAt;

    constructor(uint _startAt, uint _finishAt) {
        require(_startAt > block.timestamp, "Start must be bigger than current timestamp");
        require(_startAt < _finishAt, "Start must be lower than finish");

        startAt = Timers.Timestamp(_startAt.toUint64());
        finishAt = Timers.Timestamp(_finishAt.toUint64());
    }

    modifier onlyBeforeStart() {
        if (startAt.isExpired()) revert AlreadyStarted(startAt.getDeadline());
        _;
    }

    modifier onlyAfterStart() {
        if (startAt.isPending()) revert NotStarted(startAt.getDeadline());
        _;
    }

    modifier onlyBeforeFinish() {
        if (finishAt.isExpired()) revert AlreadyFinished(finishAt.getDeadline());
        _;
    }

    modifier onlyAfterFinish() {
        if (finishAt.isPending()) revert NotFinished(finishAt.getDeadline());
        _;
    }
}
