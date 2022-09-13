// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract PollyFeeHandler {

  function get(address for_, uint value_) public pure returns (uint) {
    if(value_ == 0)
      return 0;
    return (value_/100)*5;
  }

}
