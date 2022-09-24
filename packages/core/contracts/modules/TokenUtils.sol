// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../Polly.sol";
import "../PollyModule.sol";
import "./shared/PollyToken.sol";
import "./Meta.sol";
import "./Token1155.sol";
import "./Token721.sol";

contract TokenUtils is PMReadOnly {

  string public constant override PMNAME = 'TokenUtils';
  uint public constant override PMVERSION = 1;


  /// @notice time check
  function requireValidTime(address parent_address_, uint id_)
    public
    view
  {
    PollyToken parent_ = PollyToken(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint min_time_ = meta_.getUint(id_, "min_time");
    uint max_time_ = meta_.getUint(id_, "max_time");

    if(min_time_ > 0){
      require(block.timestamp > min_time_, "MIN_TIME_NOT_REACHED");
    }

    if(max_time_ > 0)
      require(block.timestamp < max_time_, "MAX_TIME_REACHED");
  }



  /// @notice block check
  function requireValidBlock(address parent_address_, uint id_)
    public
    view
  {
    PollyToken parent_ = PollyToken(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint min_block_ = meta_.getUint(id_, "min_block");
    uint max_block_ = meta_.getUint(id_, "max_block");

    if(min_block_ > 0){
      require(block.number > min_block_, "MIN_BLOCK_NOT_REACHED");
    }

    if(max_block_ > 0)
      require(block.number < max_block_, "MAX_BLOCK_REACHED");
  }


  /// @notice supply check
  function requireValidSupply1155(address parent_address_, uint id_, uint amount_)
    public
    view
  {

    Token1155 parent_ = Token1155(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint max_supply_ = meta_.getUint(id_, "max_supply");
    if(max_supply_ > 0){
      uint supply_ = parent_.totalSupply(id_);
      require(max_supply_ >= supply_ + amount_, 'MAX_SUPPLY_REACHED');
    }

  }


  /// @notice max mint check
  function requireValidAmount1155(address parent_address_, uint id_, uint amount_)
    public
    view
  {

    Token1155 parent_ = Token1155(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint max_mint_ = meta_.getUint(id_, "max_mint");
    if(max_mint_ > 0)
      require(max_mint_ >= amount_, 'MAX_MINT_REACHED');

  }


  /// @notice min price check
  function requireValidPrice1155(address parent_address_, uint id_, uint amount_, uint value_)
    public
    view
  {

    Token1155 parent_ = Token1155(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint min_price_ = meta_.getUint(id_, "min_price");
    if(min_price_ > 0)
      require(value_ >= (amount_*min_price_), 'INVALID_PRICE');

  }

  /// @notice min price check
  function requireValidPrice721(address parent_address_, uint id_, uint value_)
    public
    view
  {

    Token721 parent_ = Token721(parent_address_);
    Meta meta_ = parent_.getMetaHandler();
    uint min_price_ = meta_.getUint(id_, "min_price");
    if(min_price_ > 0)
      require(value_ >= min_price_, 'INVALID_PRICE');

  }

}
