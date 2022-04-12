// contracts/NFTVickreyAuction.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/INFTVickreyAuction.sol";
import "./security/TimeGuard.sol";

contract NFTVickreyAuction is Ownable, INFTVickreyAuction, TimeGuard {
    // Errors
    error BidExists(bytes32 hash);
    error AuctionAlreadyFinished(address winner, uint amount);
    error DifferentBids(bytes32 first, bytes32 second);
    error InvalidBidAmounts(uint commited, uint payed);

    // Events
    event AuctionFinished(address winner, uint amount);
    event BidRevealed(address bidder, uint amount);

    // First and second place addresses
    address public firstPlaceAddress;
    uint public firstPlaceAmount;

    address public secondPlaceAddress;
    uint public secondPlaceAmount;

    bool public isFinished;

    // Committed bids
    mapping(address => Bid) private bids;

    // Refunds
    address[] private refundAddresses;
    mapping(address => uint) private refunds;

    constructor(uint _startAt, uint _finishAt) TimeGuard(_startAt, _finishAt) {}

    // Save hashed bid
    function commitBid(bytes32 _hash) external override payable onlyAfterStart onlyBeforeFinish {
        Bid memory old = bids[msg.sender];

        if (old.hash != 0) revert BidExists(old.hash);

        bids[msg.sender] = Bid(_hash, msg.value);
    }

    // Compare hashes and change state
    function revealBid(uint _value, bytes32 _secret) external override onlyAfterFinish {
        Bid memory bid = bids[msg.sender];

        if (bid.hash != keccak256(abi.encodePacked(_value, _secret))) {
            revert DifferentBids(bid.hash, keccak256(abi.encodePacked(_value, _secret)));
        }

        if (bid.value < _value) {
            revert InvalidBidAmounts(_value, bid.value);
        }

        if (firstPlaceAmount == 0) { // Place as first if empty
            firstPlaceAddress = msg.sender;
            firstPlaceAmount = _value;
        } else if (secondPlaceAmount == 0) { // Place as second if empty
            secondPlaceAddress = msg.sender;
            secondPlaceAmount = _value;
        } else {
            if (_value > secondPlaceAmount) {
                refundAddresses.push(secondPlaceAddress);
                refunds[secondPlaceAddress] = secondPlaceAmount;

                if (_value > firstPlaceAmount) {
                    secondPlaceAmount = firstPlaceAmount;
                    secondPlaceAddress = firstPlaceAddress;

                    firstPlaceAmount = _value;
                    firstPlaceAddress = msg.sender;
                } else {
                    secondPlaceAmount = _value;
                    secondPlaceAddress = msg.sender;
                }
            } else {
                refundAddresses.push(msg.sender);
                refunds[msg.sender] = _value;
            }
        }

        emit BidRevealed(msg.sender, _value);
    }

    // Back low bids and finish
    function finish() external override onlyOwner onlyAfterFinish {
        if (isFinished) revert AuctionAlreadyFinished(firstPlaceAddress, firstPlaceAmount);

        // Winner pays second place amount
        refundAddresses.push(firstPlaceAddress);
        refunds[firstPlaceAddress] = firstPlaceAmount - secondPlaceAmount;

        refundAddresses.push(secondPlaceAddress);
        refunds[secondPlaceAddress] = secondPlaceAmount;

        for (uint i = 0; i < refundAddresses.length; i++) {
            address receiver = refundAddresses[i];
            payable(receiver).transfer(refunds[receiver]);
        }

        payable(owner()).transfer(secondPlaceAmount);
        isFinished = true;
        emit AuctionFinished(firstPlaceAddress, secondPlaceAmount);
    }
}
