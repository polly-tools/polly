//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import '../Polly.sol';
import '../PollyConfigurator.sol';

contract Hello is PMCloneKeystore {

  string public constant override PMNAME = 'Hello';
  uint public constant override PMVERSION = 1;
  string public constant override PMINFO = 'Hello World! | A simple cloneable module with keystorage for testing';

  constructor() PMCloneKeystore(){
    _setConfigurator(address(new HelloConfigurator()));
  }

  function sayHello() public view returns (string memory) {
    return string(abi.encodePacked("Hello ", get('to')._string, '!'));
  }

}

contract HelloConfigurator is PollyConfigurator {

  string public constant override FOR_PMNAME = 'Hello';
  uint public constant override FOR_PMVERSION = 2;

  function inputs() public pure override returns (string[] memory) {
    /// Inputs
    string[] memory inputs_ = new string[](1);
    inputs_[0] = "string | To | Who do you want to say hello to today?";
    return inputs_;
  }


  function outputs() public pure override returns (string[] memory) {
    /// outputs
    string[] memory outputs_ = new string[](1);
    outputs_[0] = "module | Hello | The address of the Hello module clone";
    return outputs_;
  }


  function run(Polly polly_, address for_, Polly.Param[] memory inputs_) public override returns(Polly.Param[] memory){

    // Clone a Hello module
    Hello hello_ = Hello(polly_.cloneModule(FOR_PMNAME, FOR_PMVERSION));

    // Set the string with key "to" to "World"

    if(bytes(inputs_[0]._string).length < 1)
      inputs_[0]._string = 'World';
    hello_.set(Polly.ParamType.STRING, 'to', inputs_[0]);

    // Grant roles to the address calling the configurator
    hello_.grantRole(hello_.DEFAULT_ADMIN_ROLE(), for_);
    hello_.grantRole(hello_.MANAGER(), for_);

    // Revoke all privilegies for the configurator
    hello_.revokeRole(hello_.MANAGER(), address(this));
    hello_.revokeRole(hello_.DEFAULT_ADMIN_ROLE(), address(this));

    // Return the cloned module as part of the return parameters
    Polly.Param[] memory return_ = new Polly.Param[](1);
    return_[0]._address = address(hello_);

    return return_;

  }

}
