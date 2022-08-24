//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import '../Polly.sol';
import '../PollyConfigurator.sol';
import './Json.sol';

contract Meta is PollyModule {


    struct Item {
      Json.Type _type;
      string _key;
      string _inject;
    }

    mapping(string => mapping(string => string)) private _strings;
    mapping(string => mapping(string => bool)) private _bools;
    mapping(string => mapping(string => uint)) private _uints;

    mapping(string => mapping(string => bool)) private _locked_keys;
    mapping(string => bool) private _locked_ids;


    modifier onlyUnlocked(string memory id_, string memory key_) {
      require(!isLocked(id_) && !isLocked(id_, key_), 'LOCKED');
      _;
    }

    modifier onlyManager() {
      require(isManager(msg.sender), 'ONLY_MANAGER');
      _;
    }

    /// Polly

    constructor() PollyModule(){
      _setConfigurator(address(new MetaConfigurator()));
    }

    function moduleInfo() public pure returns (IPollyModule.Info memory) {
        return IPollyModule.Info("Meta", true);
    }



    /// JSON
    function getJSON(string memory id_, Item[] memory items_, Json.Format format_) public view returns (string memory) {

      Json.Item[] memory json_items_ = new Json.Item[](items_.length);
      Item memory item;

      for (uint i = 0; i < items_.length; i++) {

        item = items_[i];

        json_items_[i]._key = item._key;
        json_items_[i]._type = item._type;

        if(item._type == Json.Type.ARRAY || item._type == Json.Type.OBJECT) {
          json_items_[i]._string = item._inject;
        } else if (item._type == Json.Type.STRING) {
          json_items_[i]._string = _strings[id_][item._key];
        } else if (item._type == Json.Type.BOOL) {
          json_items_[i]._bool = _bools[id_][item._key];
        } else if (item._type == Json.Type.NUMBER) {
          json_items_[i]._uint = _uints[id_][item._key];
        }

      }

      string memory json_ = Json(getAddress('module.Json')).get(json_items_, format_);

      return string(json_);

    }

    function _getKeyJson(string memory key_) private pure returns(string memory){
      return string(abi.encodePacked('"', key_,'":'));
    }


    /// Access
    function lockKey(string memory id_, string memory key_) public onlyManager {
        _locked_keys[id_][key_] = true;
    }

    function lockID(string memory id_) public onlyManager {
        _locked_ids[id_] = true;
    }

    function isLocked(string memory id_) public view returns (bool) {
        return _locked_ids[id_];
    }

    function isLocked(string memory id_, string memory key_) public view returns (bool) {
        return _locked_keys[id_][key_];
    }





    /// Setters
    function setString(string memory id_, string memory key_, string memory value_) public onlyManager onlyUnlocked(id_, key_) {
        _strings[id_][key_] = value_;
    }

    function setBool(string memory id_, string memory key_, bool value_) public onlyManager onlyUnlocked(id_, key_) {
        _bools[id_][key_] = value_;
    }

    function setUint(string memory id_, string memory key_, uint value_) public onlyManager onlyUnlocked(id_, key_) {
        _uints[id_][key_] = value_;
    }


    /// Getters
    function getString(string memory id_, string memory key_) public view returns (string memory) {
        return _strings[id_][key_];
    }

    function getBool(string memory id_, string memory key_) public view returns (bool) {
        return _bools[id_][key_];
    }

    function getUint(string memory id_, string memory key_) public view returns (uint) {
        return _uints[id_][key_];
    }


}


contract MetaConfigurator is PollyConfigurator {


  function info() public pure override returns (string memory, string[] memory, string[] memory) {

    string[] memory outputs_ = new string[](1);
    outputs_[0] = "module:Meta:the meta module";

    return (
      "Storage, retrieval and formatting of metadata",
      new string[](0),
      outputs_
    );

  }

  function run(Polly polly_, address for_, PollyConfigurator.Param[] memory) public override returns(PollyConfigurator.Param[] memory){

    // Clone a Meta module
    Meta meta_ = Meta(polly_.cloneModule('Meta', 1));
    Polly.Module memory json_ = polly_.getModule('Json', 1);

    meta_.setAddress('module.Json', json_.implementation);

    // Grant roles to the address calling the configurator
    meta_.grantRole(meta_.DEFAULT_ADMIN_ROLE(), for_);
    meta_.grantRole(meta_.MANAGER(), for_);

    // Revoke all privilegies for the configurator
    meta_.revokeRole(meta_.MANAGER(), address(this));
    meta_.revokeRole(meta_.DEFAULT_ADMIN_ROLE(), address(this));

    // Return the cloned module as part of the return parameters
    PollyConfigurator.Param[] memory return_ = new PollyConfigurator.Param[](1);
    return_[0]._address = address(meta_); // The address of newly cloned and configured meta module

    return return_;

  }


}
