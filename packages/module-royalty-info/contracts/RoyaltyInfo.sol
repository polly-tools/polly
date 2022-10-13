// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import '@polly-tools/core/contracts/Polly.sol';
import '@polly-tools/core/contracts/PollyModule.sol';
import '@polly-tools/polly-token/contracts/PollyToken.sol';

/// @title RoyaltyInfo
/// @author troels_a
/// @notice A PollyToken aux module for managing royalties

contract RoyaltyInfo is PMReadOnly, PollyTokenAux {

  string public constant override PMNAME = 'RoyaltyInfo';
  uint public constant override PMVERSION = 1;

  string[] private _hooks = [
    "royaltyInfo"
  ];


  function hooks() public view override returns (string[] memory) {
    return _hooks;
  }


  function royaltyInfo(address parent_, uint id_, uint value_) public view override returns (address receiver_, uint royalty_) {

    Meta meta_ = PollyToken(parent_).getMetaHandler();

    uint base_ = meta_.getUint(id_, 'royalty_base');
    receiver_ = meta_.getAddress(id_, 'royalty_recipient');

    if(base_ == 0 && meta_.getBool(0, 'royalty_base'))
      base_ = meta_.getUint(0, 'royalty_base');

    if(base_ == 0 || receiver_ == address(0))
      return (address(0), 0);

    if(base_ > 10000)
      base_ = 10000;

    royalty_ = (value_ * base_) / 10000;

    return (receiver_, royalty_);

  }

}
