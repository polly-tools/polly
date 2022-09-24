//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import './Polly.sol';



contract TestReadOnly is PMReadOnly {

  string public constant override PMNAME = 'TestReadOnly';
  uint public constant override PMVERSION = 1;

  function readValue() public pure returns(uint) {
    return 1;
  }

}



contract TestClone is PMClone {

  string public constant override PMNAME = 'TestClone';
  uint public constant override PMVERSION = 1;

  uint private _value;

  constructor() PMClone(){
    _setConfigurator(address(new TestCloneConfigurator()));
  }

  function readValue() public view returns(uint) {
    return _value;
  }

  function writeValue(uint value_) public {
    _value = value_;
  }

}


contract TestCloneConfigurator is PollyConfigurator {

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
    TestClone testClone_ = TestClone(polly_.cloneModule('TestClone', 1));

    // Grant roles to the address calling the configurator
    _transfer(address(testClone_), for_);

    // Return the cloned module as part of the return parameters
    Polly.Param[] memory return_ = new Polly.Param[](1);
    return_[0]._address = address(testClone_);
    return return_;

  }

}



// abstract contract TestCloneKeystore is PMCloneKeystore {

//   string public constant override PMNAME = 'TestCloneKeystore';
//   uint public constant override PMVERSION = 1;

//   constructor(Polly polly_) PMCloneKeystore(){
//     _setConfigurator(address(new TestCloneKeystoreConfigurator()));
//   }

//   function readValue() public view returns(uint) {
//     return get('value')._uint;
//   }

//   function writeValue(uint value_) public {
//     Polly.Param memory param_;
//     param_._uint = value_;
//     set(Polly.ParamType.UINT, 'value', param_);
//   }

// }


// contract TestCloneKeystoreConfigurator is PollyConfigurator {

//   function inputs() public pure override returns (string[] memory) {
//     /// Inputs
//     string[] memory inputs_ = new string[](1);
//     inputs_[0] = "uint | Value | What value do you want to write?";
//     return inputs_;
//   }

//   function outputs() public pure override returns (string[] memory) {
//     /// outputs
//     string[] memory outputs_ = new string[](1);
//     outputs_[0] = "module | TestCloneKeystore | The address of the TestCloneKeystore module clone";
//     return outputs_;
//   }

//   function run(Polly polly_, address for_, Polly.Param[] memory inputs_) public override payable returns(Polly.Param[] memory){

//     // Clone a TestClone module
//     TestCloneKeystore testCloneKeystore_ = TestCloneKeystore(polly_.cloneModule('TestCloneKeystore', 1));
//     // Set the uint with key "value" to 1
//     testCloneKeystore_.set(Polly.ParamType.UINT, 'value', inputs_[0]);

//     // Grant roles to the address calling the configurator
//     _transfer(address(testCloneKeystore_), for_);

//     // Return the cloned module as part of the return parameters
//     Polly.Param[] memory return_ = new Polly.Param[](1);
//     return_[0]._address = address(testCloneKeystore_);
//     return return_;

//   }

// }
