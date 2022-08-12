//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import '../Polly.sol';
import '../PollyConfigurator.sol';

contract Hello is PollyModule {

  constructor() PollyModule(){
    _setConfigurator(address(new HelloConfigurator()));
  }

  function moduleInfo() public pure returns (IPollyModule.Info memory) {
    return IPollyModule.Info("Hello", true);
  }

  function sayHello() public view returns (string memory) {
    return string(abi.encodePacked("Hello ", getString('to'), '!'));
  }

}

contract HelloConfigurator is PollyConfigurator {

  function run(Polly polly_, address for_, PollyConfigurator.InputParam[] memory) public override returns(PollyConfigurator.ReturnParam[] memory){

    // Clone a Hello module
    Hello hello_ = Hello(polly_.cloneModule('Hello', 0));
    // Set the string with key "to" to "World"
    hello_.setString('to', 'World');

    // Grant roles to the address calling the configurator
    hello_.grantRole(hello_.DEFAULT_ADMIN_ROLE(), for_);
    hello_.grantRole(hello_.MANAGER(), for_);

    // Revoke all privilegies for the configurator
    hello_.revokeRole(hello_.MANAGER(), address(this));
    hello_.revokeRole(hello_.DEFAULT_ADMIN_ROLE(), address(this));

    // Return the cloned module as part of the return parameters
    PollyConfigurator.ReturnParam[] memory return_ = new PollyConfigurator.ReturnParam[](1);
    return_[0] = PollyConfigurator.ReturnParam(
      'hello', // describe the return parameter
      '', 0, false, // Unused types of the return parameter
      address(hello_) // The address of newly cloned and configured hello module
    );

    return return_;

  }

}
