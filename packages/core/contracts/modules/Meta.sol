//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import '../Polly.sol';
import '../PollyConfigurator.sol';

contract Meta is PollyModule {

    enum Type {
      STRING, BOOL, NUMBER, INJECT
    }

    enum Format {
      KEY_VALUE, VALUE, ARRAY, OBJECT
    }

    struct JSONKey {
      string _key;
      Type _type;
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
    function getJSON(string memory id_, JSONKey[] memory keys_, Format format_) public view returns (string memory) {

      bytes[] memory parts_ = new bytes[](keys_.length);
      bytes memory append_ = ',';
      bool include_key_;

      for (uint i = 0; i < keys_.length; i++) {

        JSONKey memory key = keys_[i];

        if(i+1 == keys_.length) {
          append_ = '';
        }

        if((format_ == Format.OBJECT || format_ == Format.KEY_VALUE))
          include_key_ = true;
        else
          include_key_ = false;

        if (key._type == Type.INJECT) {
          parts_[i] = abi.encodePacked(include_key_ ? _getKeyJson(key._key) : '', key._inject, append_);
        } else if (key._type == Type.STRING) {
          parts_[i] = abi.encodePacked(include_key_ ? _getKeyJson(key._key) : '', '"', _strings[id_][key._key], '"', append_);
        } else if (key._type == Type.BOOL) {
          parts_[i] = abi.encodePacked(include_key_ ? _getKeyJson(key._key) : '', _bools[id_][key._key] ? 'true' : 'false', append_);
        } else if (key._type == Type.NUMBER) {
          parts_[i] = abi.encodePacked(include_key_ ? _getKeyJson(key._key) : '', Strings.toString(_uints[id_][key._key]), append_);
        }

      }

      bytes memory open_;
      bytes memory close_;

      if(format_ == Format.ARRAY){
        open_ = '[';
        close_ = ']';
      }
      else if(format_ == Format.OBJECT){
        open_ = '{';
        close_ = '}';
      }

      bytes memory json_;
      for (uint i = 0; i < parts_.length; i++) {
        json_ = abi.encodePacked(json_, parts_[i]);
      }
      json_ = abi.encodePacked(open_, json_, close_);


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
      "Stores and retrieves string, bool and uint values. Provides a JSON representation of the meta in various formats.",
      new string[](0),
      outputs_
    );

  }

  function run(Polly polly_, address for_, PollyConfigurator.Param[] memory) public override returns(PollyConfigurator.Param[] memory){

    // Clone a Meta module
    Meta meta_ = Meta(polly_.cloneModule('Meta', 0));

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
