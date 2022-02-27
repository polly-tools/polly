//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IModule {

  struct ModuleInfo {
    string name;
    address implementation;
    bool clone;
  }

  function init(address for_) external;
  function didInit() external view returns(bool);
  function getModuleInfo() external returns(IModule.ModuleInfo memory module_);

}


contract Module is AccessControl {

  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
  bool private _did_init = false;

  constructor(){
    init(msg.sender);
  }

  function init(address for_) public {
    require(!_did_init, 'CAN_NOT_INIT');
    _did_init = true;
    _grantRole(DEFAULT_ADMIN_ROLE, for_);
    _grantRole(MANAGER_ROLE, for_);
  }

  function didInit() public view returns(bool){
    return _did_init;
  }



}
