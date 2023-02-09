// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@polly-tools/core/contracts/Polly.sol";
import "@polly-tools/core/contracts/PollyModule.sol";
import "@polly-tools/polly-token/contracts/PollyToken.sol";
import "@polly-tools/module-meta/contracts/Meta.sol";
import "@polly-tools/module-token1155/contracts/Token1155.sol";
import "@polly-tools/module-token721/contracts/Token721.sol";

// hardhat console
import "hardhat/console.sol";

contract TokenUtils is PMReadOnly, PollyAux {
  string public constant override PMNAME = "TokenUtils";
  uint public constant override PMVERSION = 1;

  function hooks() public pure override returns(string[] memory){
    string[] memory keys_ = new string[](2);
    keys_[0] = 'action:beforeMint1155';
    keys_[1] = 'action:beforeMint721';
    return keys_;
  }

  /// @notice time check
  function requireValidTime(address parent_address_, uint id_) public view {

    PollyToken parent_ = PollyToken(parent_address_);

    uint default_min_time_ = parent_.getMetaHandler().getUint(0, "token.min_time");
    uint default_max_time_ = parent_.getMetaHandler().getUint(0, "token.max_time");
    uint min_time_ = parent_.getMetaHandler().getUint(id_, "token.min_time");
    uint max_time_ = parent_.getMetaHandler().getUint(id_, "token.max_time");

    if (min_time_ == 0) min_time_ = default_min_time_;
    if (max_time_ == 0) max_time_ = default_max_time_;

    console.log('min_time_', min_time_);
    console.log('max_time_', max_time_);

    if (min_time_ > 0) require(block.timestamp > min_time_, "MIN_TIME_NOT_REACHED");
    if (max_time_ > 0) require(block.timestamp < max_time_, "MAX_TIME_REACHED");

  }

  /// @notice block check
  function requireValidBlock(address parent_address_, uint id_) public view {

    PollyToken parent_ = PollyToken(parent_address_);

    uint min_block_ = parent_.getMeta(id_, "token.min_block")._uint;
    uint max_block_ = parent_.getMeta(id_, "token.max_block")._uint;

    if (min_block_ > 0) require(block.number >= min_block_, "MIN_BLOCK_NOT_REACHED");
    if (max_block_ > 0) require(block.number <= max_block_, "MAX_BLOCK_REACHED");

  }

  /// @notice supply check
  function requireValidSupply1155(
    address parent_address_,
    uint id_,
    uint amount_
  ) public view {

    Token1155 parent_ = Token1155(parent_address_);

    uint max_supply_ = parent_.getMeta(id_, "token.max_supply")._uint;
    if (max_supply_ > 0) {
      uint supply_ = parent_.totalSupply(id_);
      require(max_supply_ >= supply_ + amount_, "MAX_SUPPLY_REACHED");
    }
  }

  /// @notice max mint check
  function requireValidAmount1155(
    address parent_address_,
    uint id_,
    uint amount_
  ) public view {

    Token1155 parent_ = Token1155(parent_address_);

    uint max_mint_ = parent_.getMeta(id_, "token.max_mint")._uint;
    if (max_mint_ > 0) require(max_mint_ >= amount_, "MAX_MINT_REACHED");

  }

  /// @notice min price check
  function requireValidPrice1155(
    address parent_address_,
    uint id_,
    uint amount_,
    uint value_
  ) public view {
    Token1155 parent_ = Token1155(parent_address_);

    uint min_price_ = parent_.getMeta(id_, "token.min_price")._uint;
    uint max_price_ = parent_.getMeta(id_, "token.max_price")._uint;
    if(min_price_ > 0) require(value_ >= (amount_ * min_price_), "MIN_PRICE_NOT_REACHED");
    if(max_price_ > 0) require(value_ <= (amount_ * max_price_), "MAX_PRICE_REACHED");
  }

  /// @notice min price check
  function requireValidPrice721(
    address parent_address_,
    uint id_,
    uint value_
  ) public view {
    Token721 parent_ = Token721(parent_address_);

    uint min_price_ = parent_.getMeta(id_, "token.min_price")._uint;
    uint max_price_ = parent_.getMeta(id_, "token.max_price")._uint;
    if (min_price_ > 0) require(value_ >= min_price_, "INVALID_PRICE");
    if (max_price_ > 0) require(value_ <= max_price_, "INVALID_PRICE");
  }

  /// @notice existence check
  function requireTokenExists(address parent_address_, uint id_) public view {
    PollyToken parent_ = PollyToken(parent_address_);
    require(parent_.tokenExists(id_), "TOKEN_NOT_FOUND");
  }

  /// @dev internal function to run on beforeMint1155 and beforeMint721
  function _beforeMint(
    address parent_,
    uint id_,
    bool pre_,
    PollyAux.Msg memory
  ) private view {

    require(PollyToken(parent_).tokenExists(id_), "TOKEN_NOT_FOUND");

    if(!pre_){
      requireValidTime(parent_, id_);
      requireValidBlock(parent_, id_);
    }
  }

  function beforeMint1155(
    address for_,
    uint id_,
    uint amount_,
    bool pre_,
    PollyAux.Msg memory msg_
  ) public view {

    address parent_ = msg.sender;

    _beforeMint(parent_, id_, pre_, msg_);

    requireValidSupply1155(parent_, id_, amount_);
    requireValidAmount1155(parent_, id_, amount_);
    if (!pre_) requireValidPrice1155(parent_, id_, amount_, msg_._value);
  }

  function beforeMint721(
    address for_,
    uint id_,
    bool pre_,
    PollyAux.Msg memory msg_
  ) public view {

    address parent_ = msg.sender;

    _beforeMint(parent_, id_, pre_, msg_);

    if (!pre_) requireValidPrice721(parent_, id_, msg_._value);

  }


  function stringIsEmpty(string memory string_) public pure returns (bool) {
    return keccak256(abi.encodePacked(string_)) == keccak256(abi.encodePacked(''));
  }


  function stringEquals(string memory a_, string memory b_) public pure returns (bool) {
    return keccak256(abi.encodePacked(a_)) == keccak256(abi.encodePacked(b_));
  }



}
