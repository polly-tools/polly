//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '../PollyModule.sol';

contract TestModule1 is PollyModule {

  function moduleInfo() public pure returns(IPollyModule.Info memory) {
    return IPollyModule.Info("TestModule1", true);
  }

}
