
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import './Polly.sol';
import './PollyModule.sol';



abstract contract PollyConfigurator is AccessControl {

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

  bytes32 public constant MANAGER = keccak256("MANAGER");

  function info() public pure virtual returns(string memory, string[] memory, string[] memory){
    return ('', new string[](0), new string[](0));
  }

  function run(Polly polly_, address for_, PollyConfigurator.InputParam[] memory params_) public virtual returns(ReturnParam[] memory);

}
