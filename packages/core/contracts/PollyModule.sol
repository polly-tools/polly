//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Polly.sol";

interface PollyModule {

  function PMTYPE() external view returns(Polly.ModuleType);
  function PMNAME() external view returns(string memory);
  function PMVERSION() external view returns(uint);
  function PMINFO() external view returns(string memory);

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

  function PMTYPE() external view virtual returns(Polly.ModuleType);
  function PMNAME() external view virtual returns(string memory);
  function PMVERSION() external view virtual returns(uint);
  function PMINFO() external view virtual returns(string memory);

}


abstract contract PMReadOnly is PMBase {

  Polly.ModuleType public constant override PMTYPE = Polly.ModuleType.READONLY;

}


abstract contract PMClone is AccessControl, PMBase {

  Polly.ModuleType public constant override PMTYPE = Polly.ModuleType.CLONE;

  address private _configurator;
  bytes32 public constant MANAGER = keccak256("MANAGER");
  bool private _did_init = false;

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


  function _setConfigurator(address configurator_) internal {
    _configurator = configurator_;
  }

  function configurator() public view returns(address){
    return _configurator;
  }


  function isManager(address address_) public view returns(bool){
    return hasRole(MANAGER, address_);
  }

}


abstract contract PMCloneKeystore is PMClone {

  /// @dev arbitrary key-value parameters
  struct Param {
    uint _uint;
    int _int;
    bool _bool;
    string _string;
    address _address;
  }

  /// @dev locked keys
  mapping(string => bool) private _locked_keys;
  /// @dev parameters
  mapping(string => Polly.Param) private _params;

  /// @dev Locks a given key so that it can not be changed
  /// @param key_ The key to lock
  function lockKey(string memory key_) public onlyRole(DEFAULT_ADMIN_ROLE){
    _locked_keys[key_] = true;
  }

  /// @dev Check if key is locked
  /// @param key_ Key to check
  /// @return bool true if key is locked, false otherwise
  function isLockedKey(string memory key_) public view returns(bool) {
    return _locked_keys[key_];
  }

  /// @dev set param for key
  /// @param key_ key
  /// @param value_ value
  function set(Polly.ParamType type_, string memory key_, Polly.Param memory value_) public onlyRole(MANAGER){
    require(!isLockedKey(key_), 'LOCKED_KEY');
    if(type_ == Polly.ParamType.UINT){
      _params[key_]._uint = value_._uint;
    } else if(type_ == Polly.ParamType.INT){
      _params[key_]._int = value_._int;
    } else if(type_ == Polly.ParamType.BOOL){
      _params[key_]._bool = value_._bool;
    } else if(type_ == Polly.ParamType.STRING){
      _params[key_]._string = value_._string;
    } else if(type_ == Polly.ParamType.ADDRESS){
      _params[key_]._address = value_._address;
    }
  }

  /// @dev get param for key
  /// @param key_ key
  /// @return value
  function get(string memory key_) public view returns(Polly.Param memory){
    return _params[key_];
  }


}
