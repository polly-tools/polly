//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '../PollyModule.sol';
import '../PollyConfigurator.sol';


// Clonable module

contract TestModule2 is PollyModule {

  constructor() PollyModule() {
    _setConfigurator(address(new TestModule2Configurator()));
  }

  function moduleInfo() public pure returns(IPollyModule.Info memory) {
    return IPollyModule.Info("TestModule2", true);
  }

}

contract TestModule2Configurator is PollyConfigurator {

  function info() public pure override returns(string memory, string[] memory, string[] memory) {
    string[] memory outputs_ = new string[](1);
    outputs_[0] = "module:TestModule2:the instance of the deployed module";
    return ("TestModuleConfigurator", new string[](0), outputs_);
  }

  function run(Polly polly_, address for_, PollyConfigurator.Param[] memory) public override returns(Param[] memory){

    address self_ = address(this);

    Param[] memory ret_ = new Param[](1);

    // Clone a Hello module
    TestModule2 mod_ = TestModule2(polly_.cloneModule('TestModule2', 0));

    // Grant roles to the address calling the configurator
    mod_.grantRole(mod_.DEFAULT_ADMIN_ROLE(), for_);
    mod_.grantRole(mod_.MANAGER(), for_);

    // Revoke all privilegies for the configurator
    mod_.revokeRole(mod_.MANAGER(), self_);
    mod_.revokeRole(mod_.DEFAULT_ADMIN_ROLE(), self_);

    ret_[0]._address = address(mod_);

    return ret_;

  }

}
