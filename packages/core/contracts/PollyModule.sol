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

  function init(address for_) external;
  function didInit() external view returns(bool);
  function getInfo() external view returns(IPollyModule.Info memory module_);
  function setString(string memory key_, string memory value_) external;
  function setInt(string memory key_, uint value_) external;
  function setAddress(string memory key_, address value_) external;
  function setBool(string memory key_, bool value_) external;
  function getString(string memory key_) external view returns(string memory);
  function getInt(string memory key_) external view returns(int);
  function getAddress(string memory key_) external view returns(address);
  function getBool(string memory key_) external view returns(bool);
  function isManager(address address_) external view returns(bool);

}


contract PollyModule is AccessControl {

  bytes32 public constant MANAGER = keccak256("MANAGER");
  bool private _did_init = false;
  mapping(string => string) private _keyStoreStrings;
  mapping(string => int) private _keyStoreInts;
  mapping(string => bool) private _keyStoreBool;
  mapping(string => address) private _keyStoreAddresses;

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

  function setString(string memory key_, string memory value_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _keyStoreStrings[key_] = value_;
  }
  function setInt(string memory key_, int value_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _keyStoreInts[key_] = value_;
  }
  function setAddress(string memory key_, address value_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _keyStoreAddresses[key_] = value_;
  }
  function setBool(string memory key_, bool value_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _keyStoreBool[key_] = value_;
  }
  function getString(string memory key_) public view returns(string memory) {
    return _keyStoreStrings[key_];
  }
  function getInt(string memory key_) public view returns(int) {
    return _keyStoreInts[key_];
  }
  function getAddress(string memory key_) public view returns(address) {
    return _keyStoreAddresses[key_];
  }
  function getBool(string memory key_) public view returns(bool) {
    return _keyStoreBool[key_];
  }
  function isManager(address address_) external view returns(bool){
    return hasRole(MANAGER, address_);
  }

}
