
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import './Polly.sol';
import './PollyModule.sol';

interface PollyConfigurator {

  function FOR_PMNAME() external pure returns (string memory);
  function FOR_PMVERSION() external pure returns (uint);

  function inputs() external pure returns (string[] memory);
  function outputs() external pure returns (string[] memory);
  function run(Polly polly_, address for_, Polly.Param[] memory params_) external returns(Polly.Param[] memory);

}
