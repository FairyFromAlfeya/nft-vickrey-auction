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

    Timers.Timestamp public start;
    Timers.Timestamp public finish;

    constructor(uint _startAt, uint _finishAt) {
        require(_startAt > block.timestamp, "Start must be bigger than current timestamp");
        require(_startAt < _finishAt, "Start must be lower than finish");

        start = Timers.Timestamp(_startAt.toUint64());
        finish = Timers.Timestamp(_finishAt.toUint64());
    }

    modifier onlyBeforeStart() {
        if (start.isExpired()) revert AlreadyStarted(start.getDeadline());
        _;
    }

    modifier onlyAfterStart() {
        if (start.isPending()) revert NotStarted(start.getDeadline());
        _;
    }

    modifier onlyBeforeFinish() {
        if (finish.isExpired()) revert AlreadyFinished(finish.getDeadline());
        _;
    }

    modifier onlyAfterFinish() {
        if (finish.isPending()) revert NotFinished(finish.getDeadline());
        _;
    }
}
