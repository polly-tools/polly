//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;


interface IInitializable {

  function init() external;
  function didInit() external view returns(bool);

}

contract Initializable {

  bool private _did_init = false;

  function init() public virtual {
    require(!_did_init, 'CANNOT INIT TWICE');
    _did_init = true;
  }

  function didInit() public view returns(bool){
    return _did_init;
  }

}
