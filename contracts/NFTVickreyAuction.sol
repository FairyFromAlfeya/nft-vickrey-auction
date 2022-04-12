// contracts/NFTVickreyAuction.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interfaces/INFTVickreyAuction.sol";
import "./security/TimeGuard.sol";

contract NFTVickreyAuction is Ownable, INFTVickreyAuction, TimeGuard, IERC721Receiver {
    using SafeMath for uint256;

    // Events
    event AuctionFinished(address winner, uint amount);
    event BidRevealed(address bidder, uint amount);

    // First and second place addresses
    address public firstPlaceAddress;
    uint public firstPlaceAmount;

    address public secondPlaceAddress;
    uint public secondPlaceAmount;

    bool public isFinished;
    bool public isStarted;

    // Committed bids
    mapping(address => Bid) private bids;

    // Refunds
    address[] private refundAddresses;
    mapping(address => uint) private refunds;

    IERC721 private erc721;
    uint public nftId;

    constructor(uint _startAt, uint _finishAt) TimeGuard(_startAt, _finishAt) {}

    // Save hashed bid
    function commitBid(bytes32 _hash) external override payable onlyAfterStart onlyBeforeFinish {
        Bid memory old = bids[msg.sender];

        require(old.hash == 0, "Bid exists");

        bids[msg.sender] = Bid(_hash, msg.value);
    }

    // Compare hashes and change state
    function revealBid(uint _value, bytes32 _secret) external override onlyAfterFinish {
        Bid memory bid = bids[msg.sender];

        require(bid.hash == keccak256(abi.encodePacked(_value, _secret)), "Bids are different");

        require(bid.value >= _value, "Invalid amount");

        if (_value > secondPlaceAmount) {
            if (_value > firstPlaceAmount) {
                _placeInsteadFirst(msg.sender, _value);
            } else {
                _placeInsteadSecond(msg.sender, _value);
            }
        } else {
            _placeToRefund(msg.sender, _value);
        }

        emit BidRevealed(msg.sender, _value);
    }

    function init(IERC721 _erc721, uint _nftId) external override onlyOwner onlyBeforeStart {
        require(!isStarted, "Auction is started");

        erc721 = _erc721;
        nftId = _nftId;
        erc721.safeTransferFrom(msg.sender, address(this), _nftId);
    }

    // Back low bids and finish
    function finish() external override onlyOwner onlyAfterFinish {
        require(!isFinished, "Auction is finished");

        // Winner pays second place amount
        payable(firstPlaceAddress).transfer(firstPlaceAmount.sub(secondPlaceAmount, "First place amount is less than second"));
        payable(secondPlaceAddress).transfer(secondPlaceAmount);

        for (uint i = 0; i < refundAddresses.length; i++) {
            address receiver = refundAddresses[i];
            payable(receiver).transfer(refunds[receiver]);
        }

        payable(owner()).transfer(secondPlaceAmount);
        erc721.transferFrom(address(this), firstPlaceAddress, nftId);
        isFinished = true;

        emit AuctionFinished(firstPlaceAddress, secondPlaceAmount);
    }

    function _placeInsteadFirst(address _address, uint _amount) private {
        _placeInsteadSecond(firstPlaceAddress, firstPlaceAmount);

        // Place instead first
        firstPlaceAmount = _amount;
        firstPlaceAddress = _address;
    }

    function _placeInsteadSecond(address _address, uint _amount) private {
        // Move second to refund
        _placeToRefund(secondPlaceAddress, secondPlaceAmount);

        // Place instead second
        secondPlaceAmount = _amount;
        secondPlaceAddress = _address;
    }

    function _placeToRefund(address _address, uint _amount) private {
        if (_address != address(0)) {
            refundAddresses.push(_address);
            refunds[msg.sender] = _amount;
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
