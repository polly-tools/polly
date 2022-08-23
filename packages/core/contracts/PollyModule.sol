//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IPollyModule {

  struct Info {
    string name;
    bool clone;
  }

  // Read-only
  function moduleInfo() external view returns(Info memory module_);

  // Clonable
  function init(address for_) external;
  function didInit() external view returns(bool);
  function configurator() external view returns(address);
  function isManager(address address_) external view returns(bool);

  // Utility functions
  function lockKey(string memory key_) external;
  function isLockedKey(string memory key_) external view returns(bool);
  function setInt(string memory key_, int value_) external;
  function setString(string memory key_, string memory value_) external;
  function setAddress(string memory key_, address value_) external;
  function getInt(string memory key_) external view returns(int);
  function getString(string memory key_) external view returns(string memory);
  function getAddress(string memory key_) external view returns(address);

}

contract BasePollyModule {

  address private _configurator;
  uint public constant PMVERSION = 1;

  function _setConfigurator(address configurator_) internal {
    _configurator = configurator_;
  }

  function configurator() public view returns(address){
    return _configurator;
  }

}


contract PollyModule is AccessControl, BasePollyModule {

  bytes32 public constant MANAGER = keccak256("MANAGER");
  bool private _did_init = false;

  mapping(string => bool) private _locked_keys;
  mapping(string => string) private _key_strings;
  mapping(string => int) private _key_ints;
  mapping(string => address) private _key_addresses;


  constructor(){
    init(msg.sender);
  }

  function init(address for_) public virtual {
    require(!_did_init, 'CAN_NOT_INIT');
    _did_init = true;
    _grantRole(DEFAULT_ADMIN_ROLE, for_);
    _grantRole(MANAGER, for_);
  }

  function didInit() public view returns(bool){
    return _did_init;
  }


  function lockKey(string memory key_) public onlyRole(DEFAULT_ADMIN_ROLE){
    _locked_keys[key_] = true;
  }

  function isLockedKey(string memory key_) public view returns(bool) {
    return _locked_keys[key_];
  }

  function _reqUnlockedKey(string memory key_) private view {
    require(!isLockedKey((key_)), 'KEY_IS_LOCKED');
  }

  function setInt(string memory key_, int value_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _reqUnlockedKey(key_);
    _key_ints[key_] = value_;
  }


  function setString(string memory key_, string memory value_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _reqUnlockedKey(key_);
    _key_strings[key_] = value_;
  }

  function setAddress(string memory key_, address value_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _reqUnlockedKey(key_);
    _key_addresses[key_] = value_;
  }

  function getInt(string memory key_) public view returns(int) {
    return _key_ints[key_];
  }

  function getString(string memory key_) public view returns(string memory) {
    return _key_strings[key_];
  }

  function getAddress(string memory key_) public view returns(address) {
    return _key_addresses[key_];
  }

  function isManager(address address_) public view returns(bool){
    return hasRole(MANAGER, address_);
  }

}
