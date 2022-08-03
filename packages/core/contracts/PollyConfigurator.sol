
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import './PollyModule.sol';


abstract contract PollyConfigurator is PollyModule {

  struct InputParam {
    string _string;
    int _int;
    bool _bool;
    address _address;
  }

  struct ReturnParam {
    string key;
    string _string;
    int _int;
    bool _bool;
    address _address;
  }


  function run(address for_, PollyConfigurator.InputParam[] memory params_) public virtual returns(ReturnParam[] memory);

}
