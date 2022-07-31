//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '../PollyModule.sol';

contract TestModule1 is PollyModule {

  function getModuleInfo() public view returns(IPollyModule.ModuleInfo memory) {
    return IPollyModule.ModuleInfo("TestModule1", address(this), true);
  }

}
