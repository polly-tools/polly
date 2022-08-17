//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import '../Polly.sol';
import 'base64-sol/base64.sol';

contract Meta is PollyModule {

    struct JSONKey {
        string _key;
        uint _type;
    }

    mapping(string => mapping(string => string)) private _strings;
    mapping(string => mapping(string => bool)) private _bools;
    mapping(string => mapping(string => uint)) private _uints;

    mapping(string => mapping(string => bool)) private _locked;


    modifier isUnlockedKey(string memory id_, string memory key_) {
      require(!isLockedKey(id_, key_), 'KEY_LOCKED');
      _;
    }

    modifier onlyManager() {
      require(!isManager(msg.sender), 'KEY_LOCKED');
      _;
    }

    /// Polly
    function getModuleInfo() public pure returns (IPollyModule.Info memory) {
        return IPollyModule.Info("Meta", true);
    }


    /// JSON
    function getJSON(string memory id_, JSONKey[] memory keys_) public view returns (string memory) {

      bytes[] memory parts_ = new bytes[](keys_.length);
      string memory append_ = ',';

      for (uint i = 0; i < keys_.length; i++) {
        JSONKey memory key = keys_[i];

        if(i+1 == keys_.length) {
          append_ = '';
        }

        if (key._type == 0) {
          parts_[i] = abi.encodePacked('"', key._key,'":', getJSON(_strings[id_][key._key]), append_);
        } else if (key._type == 1) {
          parts_[i] = abi.encodePacked('"', key._key,'": "', _strings[id_][key._key], '"', append_);
        } else if (key._type == 2) {
          parts_[i] = abi.encodePacked('"', key._key,'": ', _bools[id_][key._key] ? 'true' : 'false', append_);
        } else if (key._type == 3) {
          parts_[i] = abi.encodePacked('"', key._key,'": ', Strings.toString(_uints[id_][key._key]), append_);
        }

      }

      bytes memory json_ = '{';
      for (uint i = 0; i < parts_.length; i++) {
        json_ = abi.encodePacked(json_, parts_[i]);
      }
      abi.encodePacked(json_, '}');


      return string(abi.encodePacked('data:application/json;base64,', Base64.encode(json_)));

    }


    /// Access
    function lockKey(string memory id_, string memory key_) public {
        _locked[id_][key_] = true;
    }

    function isLockedKey(string memory id_, string memory key_) public view returns (bool) {
        return _locked[id_][key_];
    }




    /// Setters
    function setString(string memory id_, string memory key_, string memory value_) public onlyManager isUnlockedKey(id_, key_) {
        _strings[id_][key_] = value_;
    }

    function setBool(string memory id_, string memory key_, bool value_) public onlyManager isUnlockedKey(id_, key_) {
        _bools[id_][key_] = value_;
    }

    function setInt(string memory id_, string memory key_, uint value_) public onlyManager isUnlockedKey(id_, key_) {
        _uints[id_][key_] = value_;
    }


    /// Getters
    function getString(string memory id_, string memory key_) public view returns (string memory) {
        return _strings[id_][key_];
    }

    function getBool(string memory id_, string memory key_) public view returns (bool) {
        return _bools[id_][key_];
    }

    function getInts(string memory id_, string memory key_) public view returns (uint) {
        return _uints[id_][key_];
    }


}
