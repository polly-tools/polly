
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import './Polly.sol';
import './PollyModule.sol';

abstract contract BasePollyConfigurator {
  function info() public pure virtual returns(string memory, string[] memory, string[] memory);
}

abstract contract PollyConfigurator is BasePollyConfigurator {

  struct Param {
    string _string;
    int _int;
    bool _bool;
    address _address;
  }

  bytes32 public constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");
  bytes32 public constant MANAGER = keccak256("MANAGER");

  function run(Polly polly_, address for_, PollyConfigurator.Param[] memory params_) public virtual returns(Param[] memory);

}
