//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import './Polly.sol';



contract TestReadOnly_v1 is PMReadOnly {

  string public constant override PMNAME = 'TestReadOnly';
  uint public constant override PMVERSION = 1;

  function readValue() public pure returns(uint) {
    return 1;
  }

}



contract TestClone_v1 is PMClone {

  string public constant override PMNAME = 'TestClone';
  uint public constant override PMVERSION = 1;

  uint private _value;

  constructor() PMClone(){
    _setConfigurator(address(new TestCloneConfigurator_v1()));
  }

  function readValue() public view returns(uint) {
    return _value;
  }

  function writeValue(uint value_) public {
    _value = value_;
  }

}


contract TestCloneConfigurator_v1 is PollyConfigurator {

  function inputs() public pure override returns (string[] memory) {
    /// Inputs
    string[] memory inputs_ = new string[](1);
    inputs_[0] = "uint | Value | What value do you want to write?";
    return inputs_;
  }

  function outputs() public pure override returns (string[] memory) {
    /// outputs
    string[] memory outputs_ = new string[](1);
    outputs_[0] = "module | TestClone | The address of the TestClone module clone";
    return outputs_;
  }

  function run(Polly polly_, address for_, Polly.Param[] memory) public override payable returns(Polly.Param[] memory){

    // Clone a TestClone module
    TestClone_v1 testClone_ = TestClone_v1(polly_.cloneModule('TestClone', 1));

    // Grant roles to the address calling the configurator
    _transfer(address(testClone_), for_);

    // Return the cloned module as part of the return parameters
    Polly.Param[] memory return_ = new Polly.Param[](1);
    return_[0]._address = address(testClone_);
    return return_;

  }

}
