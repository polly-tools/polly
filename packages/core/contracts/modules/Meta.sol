//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import '../Polly.sol';
import '../PollyConfigurator.sol';
import './Json.sol';


contract Meta is PMClone {

  Json private _json_parser;
  string public constant override PMNAME = 'Meta';
  uint public constant override PMVERSION = 1;
  string public constant override PMINFO = 'Meta | storage and retrieval of metadata';

  struct Item {
    Json.Type _type;
    string _key;
    address _address;
    string _inject;
  }

  mapping(string => Polly.Param) private _keys;
  mapping(string => bool) private _locked_keys;

  mapping(address => mapping(string => Polly.Param)) private _address_keys;
  mapping(address => mapping(string => bool)) private _locked_address_keys;
  mapping(address => bool) private _allowed_address;
  mapping(address => bool) private _locked_address;

  modifier onlyManager() {
    require(isManager(msg.sender), 'ONLY_MANAGER');
    _;
  }


  constructor() PMClone(){
    _setConfigurator(address(new MetaConfigurator()));
  }


  function setJsonParser(address json_parser) public onlyManager {
    _json_parser = Json(json_parser);
  }



  /// JSON
  function getJSON(Item[] memory items_, Json.Format format_) public view returns (string memory) {

    Json.Item[] memory json_items_ = new Json.Item[](items_.length);
    Item memory item;

    for (uint i = 0; i < items_.length; i++) {

      item = items_[i];

      json_items_[i]._key = item._key;
      json_items_[i]._type = item._type;

      if(item._type == Json.Type.ARRAY || item._type == Json.Type.OBJECT) {
        json_items_[i]._string = item._inject;
      } else if (item._type == Json.Type.STRING) {
        if(item._address != address(0)) {
          json_items_[i]._string = _address_keys[item._address][item._key]._string;
        } else {
          json_items_[i]._string = _keys[item._key]._string;
        }
      } else if (item._type == Json.Type.BOOL) {
        if(item._address != address(0)) {
          json_items_[i]._bool = _address_keys[item._address][item._key]._bool;
        } else {
          json_items_[i]._bool = _keys[item._key]._bool;
        }
      } else if (item._type == Json.Type.NUMBER) {
        if(item._address != address(0)) {
          json_items_[i]._uint = _address_keys[item._address][item._key]._uint;
        } else {
          json_items_[i]._uint = _keys[item._key]._uint;
        }
      }

    }

    string memory json_ = _json_parser.encode(json_items_, format_);

    return string(json_);

  }

  function _getKeyJson(string memory key_) private pure returns(string memory){
    return string(abi.encodePacked('"', key_,'":'));
  }


  /// Access
  function lockKey(string memory key_) public onlyManager {
    _locked_keys[key_] = true;
  }

  function isLockedKey(string memory key_) public view returns (bool) {
    return _locked_keys[key_];
  }

  function allowAddress(address address_) public onlyManager {
    _allowed_address[address_] = false;
  }

  function lockAddress(address address_) public onlyManager {
    _locked_address[address_] = true;
  }

  function lockAddressKey(address address_, string memory key_) public onlyManager {
    _locked_address_keys[address_][key_] = true;
  }

  function isLockedAddress(address address_) public view returns (bool) {
    return _locked_address[address_];
  }

  function isLockedAddressKey(address address_, string memory key_) public view returns (bool) {
    return _locked_address_keys[address_][key_];
  }


  /// Setters
  function setKey(string memory key_, Polly.Param memory param_) public onlyManager {
    require(!isLockedKey(key_), 'KEY_LOCKED');
    _keys[key_] = param_;
  }

  function setAddressKey(address address_, string memory key_, Polly.Param memory param_) public onlyManager {
    require(_allowed_address[address_], 'ADDRESS_NOT_ALLOWED');
    require(!isLockedAddress(address_), 'ADDRESS_LOCKED');
    require(!isLockedAddressKey(address_, key_), 'ADDRESS_KEY_LOCKED');
    _address_keys[address_][key_] = param_;
  }

  /// Getters

  function getKey(string memory key_) public view returns (Polly.Param memory) {
    return _keys[key_];
  }

  function getAddressKey(address address_, string memory key_) public view returns (Polly.Param memory) {
    return _address_keys[address_][key_];
  }


}


contract MetaConfigurator is PollyConfigurator {

  string public constant override FOR_PMNAME = 'Meta';
  uint public constant override FOR_PMVERSION = 1;

  function inputs() public pure override returns (string[] memory) {

    string[] memory outputs_ = new string[](1);
    outputs_[0] = "module | Meta | the meta module";

    return outputs_;

  }

  function outputs() public pure override returns (string[] memory) {

    string[] memory outputs_ = new string[](1);
    outputs_[0] = "module | Meta | the meta module";

    return outputs_;

  }

  function run(Polly polly_, address for_, Polly.Param[] memory) public override returns(Polly.Param[] memory){

    // Clone a Meta module)
    Meta meta_ = Meta(polly_.cloneModule('Meta', 1));

    // Set the json module to use
    meta_.setJsonParser(polly_.getModule('Json', 1).implementation);

    // Grant roles to the address calling the configurator
    meta_.grantRole(meta_.DEFAULT_ADMIN_ROLE(), for_);
    meta_.grantRole(meta_.MANAGER(), for_);

    // Revoke all privilegies for the configurator
    meta_.revokeRole(meta_.MANAGER(), address(this));
    meta_.revokeRole(meta_.DEFAULT_ADMIN_ROLE(), address(this));

    // Return the cloned module as part of the return parameters
    Polly.Param[] memory return_ = new Polly.Param[](1);
    return_[0]._address = address(meta_); // The address of newly cloned and configured meta module

    return return_;

  }


}
