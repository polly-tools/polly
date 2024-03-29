//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '../PollyModule.sol';


// Clonable module

contract TestModule2 is PollyModule {

  function moduleInfo() public pure returns(IPollyModule.Info memory) {
    return IPollyModule.Info("TestModule2", true);
  }

}
