//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Polly.sol";

/// @dev full interface for a PollyModule
interface PollyModule {

  function PMTYPE() external view returns(Polly.ModuleType);
  function PMNAME() external view returns(string memory);
  function PMVERSION() external view returns(uint);

  // Clonable
  function init(address for_) external;
  function didInit() external view returns(bool);
  function configurator() external view returns(address);
  function isManager(address address_) external view returns(bool);

  // Keystore
  function lockKey(string memory key_) external;
  function isLockedKey(string memory key_) external view returns(bool);
  function set(Polly.ParamType type_, string memory key_, Polly.Param memory value_) external;
  function get(string memory key_) external view returns(Polly.Param memory value_);

}


abstract contract PMBase {

  address private _configurator;

  function PMTYPE() external view virtual returns(Polly.ModuleType);
  function PMNAME() external view virtual returns(string memory);
  function PMVERSION() external view virtual returns(uint);

  // Configuration
  function _setConfigurator(address configurator_) internal {
    _configurator = configurator_;
  }

  function configurator() public view returns(address){
    return _configurator;
  }

}


abstract contract PMReadOnly is PMBase {

  Polly.ModuleType public constant override PMTYPE = Polly.ModuleType.READONLY;

}


abstract contract PMClone is PMBase {

  Polly.ModuleType public constant override PMTYPE = Polly.ModuleType.CLONE;

  bool private _did_init = false;

  address private _owner;
  mapping(address => mapping(string => bool)) private _roles;

  modifier onlyRole(string memory role_){
    require(hasRole(role_, msg.sender), string(abi.encodePacked('MISSING_ROLE: ', role_, ' - ', Strings.toHexString(uint160(msg.sender), 20))));
    _;
  }


  // Initialization
  constructor(){
    init(msg.sender);
  }

  function init(address for_) public virtual {
    require(!_did_init, 'ALREADY_INITIALIZED');
    _did_init = true;
    _grantRole('admin', for_);
    _grantRole('manager', for_);
  }

  function didInit() public view returns(bool){
    return _did_init;
  }


  /// Access control

  function _requireRole(string memory role_, address address_) internal view {
    require(hasRole(role_, address_), string(abi.encodePacked('MISSING_ROLE: ', role_, ' - ', Strings.toHexString(uint160(address_), 20))));
  }

  function owner() public view returns(address){
    return _owner;
  }

  function _setOwner(address new_owner_) internal {
    _owner = new_owner_;
    _grantRole('admin', new_owner_);
  }

  function setOwner(address new_owner_) public {
    _requireRole('admin', msg.sender);
    _setOwner(new_owner_);
  }

  function hasRole(string memory role_, address check_) public view returns(bool){
    return _roles[check_][role_];
  }

  function _grantRole(string memory role_, address to_) internal {
    _roles[to_][role_] = true;
  }

  function grantRole(string memory role_, address to_) public {
    _requireRole('admin', msg.sender);
    _grantRole(role_, to_);
  }

  function revokeRole(string memory role_, address to_) public {
    _requireRole('admin', msg.sender);
    _roles[to_][role_] = false;
  }

  function renounceRole(string memory role_) public {
    _requireRole(role_, msg.sender);
    _roles[msg.sender][role_] = false;
  }


}


// abstract contract PMCloneKeystore is PMClone {

//   /// @dev arbitrary key-value parameters
//   struct Param {
//     uint _uint;
//     int _int;
//     bool _bool;
//     string _string;
//     address _address;
//   }

//   /// @dev locked keys
//   mapping(string => bool) private _locked_keys;
//   bool private _locked;
//   /// @dev parameters
//   mapping(string => Polly.Param) private _params;

//   /// @dev Locks a given key so that it can not be changed
//   /// @param key_ The key to lock
//   function lockKey(string memory key_) public onlyRole('admin'){
//     _locked_keys[key_] = true;
//   }

//   /// @dev Lock all keys so that they can not be changed
//   function lock() public onlyRole('admin'){
//     _locked = true;
//   }

//   /// @dev Check if key is locked
//   /// @param key_ Key to check
//   /// @return bool true if key is locked, false otherwise
//   function isLockedKey(string memory key_) public view returns(bool) {
//     return _locked_keys[key_];
//   }

//   /// @dev Check if all keys are locked
//   /// @return bool true if all keys are locked, false otherwise
//   function isLocked() public view returns(bool) {
//     return _locked;
//   }

//   /// @dev set param for key
//   /// @param key_ key
//   /// @param value_ value
//   function set(Polly.ParamType type_, string memory key_, Polly.Param memory value_) public onlyRole('manager'){
//     require(!isLocked(), 'ALL_KEYS_LOCKED');
//     require(!isLockedKey(key_), 'LOCKED_KEY');
//     if(type_ == Polly.ParamType.UINT){
//       _params[key_]._uint = value_._uint;
//     } else if(type_ == Polly.ParamType.INT){
//       _params[key_]._int = value_._int;
//     } else if(type_ == Polly.ParamType.BOOL){
//       _params[key_]._bool = value_._bool;
//     } else if(type_ == Polly.ParamType.STRING){
//       _params[key_]._string = value_._string;
//     } else if(type_ == Polly.ParamType.ADDRESS){
//       _params[key_]._address = value_._address;
//     }
//   }

//   /// @dev get param for key
//   /// @param key_ key
//   /// @return value
//   function get(string memory key_) public view returns(Polly.Param memory){
//     return _params[key_];
//   }


// }
