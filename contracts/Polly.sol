//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "./Collection.sol";
import "./Catalogue.sol";
import "./Meta.sol";
import "./Aux.sol";
import "./Module.sol";


interface IPolly {

  struct Instance {
    address owner;
    address coll;
    address cat;
    address meta;
    address aux_handler;
  }

}


contract Polly is Ownable {




    /// PROPERTIES ///

    mapping(string => mapping(uint => address)) private _modules;
    mapping(string => uint) private _module_versions;

    //////////////////




    /// EVENTS ///

    event moduleUpdated(
      string indexed name,
      uint indexed version,
      address indexed implementation
    );

    event moduleUse(
      string indexed name,
      address indexed module_address,
      address indexed deployer
    );


    //////////////




    function updateModule(string memory name_, address implementation_) public onlyOwner {

      bool update = false;

      _module_versions[name_]++;
      _modules[name_][_module_versions[name_]] = implementation_;

      if(update)
        emit moduleUpdated(name_, _module_versions[name_], implementation_);

    }



    function useModule(string memory name_, uint version_) public returns(address module_address_) {

      require(moduleExists(name_, version_), 'MODULE_DOES_NOT_EXIST');
      IModule.ModuleInfo memory module_info_ = IModule(_modules[name_][version_]).getModuleInfo();
      require(module_info_.clone, 'MODULE_NOT_DEPLOYABLE');

      IModule module_ = IModule(Clones.clone(_modules[name_][version_]));
      module_.init(msg.sender);

      module_address_ = address(module_);

      emit moduleUse(name_, module_address_, msg.sender);

      return module_address_;

    }



    function getModuleVersion(string memory name_) public view returns(uint){
      return _module_versions[name_];
    }



    function moduleExists(string memory name_, uint version_) public view returns(bool exists_){
      if(_modules[name_][version_] != address(0))
        exists_ = true;
      return exists_;
    }



}
