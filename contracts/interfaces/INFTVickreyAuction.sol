// contracts/interfaces/INFTVickreyAuction.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INFTVickreyAuction {
    struct Bid {
        bytes32 hash;
        uint value;
    }

    function commitBid(bytes32 _hash) external payable;

    function revealBid(uint _value, bytes32 _secret) external;

    function finish() external;
}
