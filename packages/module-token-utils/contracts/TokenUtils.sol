// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@polly-tools/core/contracts/Polly.sol";
import "@polly-tools/core/contracts/PollyModule.sol";
import "@polly-tools/polly-token/contracts/PollyToken.sol";
import "@polly-tools/module-meta/contracts/Meta.sol";
import "@polly-tools/module-token1155/contracts/Token1155.sol";
import "@polly-tools/module-token721/contracts/Token721.sol";

contract TokenUtils is PMReadOnly, PollyTokenAux {
  string public constant override PMNAME = "TokenUtils";
  uint256 public constant override PMVERSION = 1;

  /// @notice time check
  function requireValidTime(address parent_address_, uint256 id_) public view {
    PollyToken parent_ = PollyToken(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint256 min_time_ = meta_.getUint(id_, "min_time");
    uint256 max_time_ = meta_.getUint(id_, "max_time");

    if (min_time_ > 0) {
      require(block.timestamp > min_time_, "MIN_TIME_NOT_REACHED");
    }

    if (max_time_ > 0) require(block.timestamp < max_time_, "MAX_TIME_REACHED");
  }

  /// @notice block check
  function requireValidBlock(address parent_address_, uint256 id_) public view {
    PollyToken parent_ = PollyToken(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint256 min_block_ = meta_.getUint(id_, "min_block");
    uint256 max_block_ = meta_.getUint(id_, "max_block");

    if (min_block_ > 0) {
      require(block.number > min_block_, "MIN_BLOCK_NOT_REACHED");
    }

    if (max_block_ > 0) require(block.number < max_block_, "MAX_BLOCK_REACHED");
  }

  /// @notice supply check
  function requireValidSupply1155(
    address parent_address_,
    uint256 id_,
    uint256 amount_
  ) public view {
    Token1155 parent_ = Token1155(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint256 max_supply_ = meta_.getUint(id_, "max_supply");
    if (max_supply_ > 0) {
      uint256 supply_ = parent_.totalSupply(id_);
      require(max_supply_ >= supply_ + amount_, "MAX_SUPPLY_REACHED");
    }
  }

  /// @notice max mint check
  function requireValidAmount1155(
    address parent_address_,
    uint256 id_,
    uint256 amount_
  ) public view {
    Token1155 parent_ = Token1155(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint256 max_mint_ = meta_.getUint(id_, "max_mint");
    if (max_mint_ > 0) require(max_mint_ >= amount_, "MAX_MINT_REACHED");
  }

  /// @notice min price check
  function requireValidPrice1155(
    address parent_address_,
    uint256 id_,
    uint256 amount_,
    uint256 value_
  ) public view {
    Token1155 parent_ = Token1155(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint256 min_price_ = meta_.getUint(id_, "min_price");
    if (min_price_ > 0)
      require(value_ >= (amount_ * min_price_), "INVALID_PRICE");
  }

  /// @notice min price check
  function requireValidPrice721(
    address parent_address_,
    uint256 id_,
    uint256 value_
  ) public view {
    Token721 parent_ = Token721(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint256 min_price_ = meta_.getUint(id_, "min_price");
    if (min_price_ > 0) require(value_ >= min_price_, "INVALID_PRICE");
  }

  /// @dev internal function to run on beforeMint1155 and beforeMint721
  function _beforeMint(
    address parent_,
    uint256 id_,
    bool pre_,
    PollyAux.Msg memory
  ) private view {
    require(PollyToken(parent_).tokenExists(id_), "TOKEN_NOT_FOUND");
    if (!pre_)
      requireValidTime(parent_, id_);
  }

  function beforeMint1155(
    address parent_,
    uint256 id_,
    uint256 amount_,
    bool pre_,
    PollyAux.Msg memory msg_
  ) public view override {
    _beforeMint(parent_, id_, pre_, msg_);

    requireValidSupply1155(parent_, id_, amount_);
    requireValidAmount1155(parent_, id_, amount_);
    if (!pre_) requireValidPrice1155(parent_, id_, amount_, msg_._value);
  }

  function beforeMint721(
    address parent_,
    uint256 id_,
    bool pre_,
    PollyAux.Msg memory msg_
  ) public view override {
    _beforeMint(parent_, id_, pre_, msg_);
    if (!pre_) requireValidPrice721(parent_, id_, msg_._value);
  }

  function hooks() public view virtual override returns (string[] memory) {

    string[] memory hooks_ = new string[](2);
    hooks_[0] = "beforeMint1155";
    hooks_[1] = "beforeMint721";
    return hooks_;
  }

}
