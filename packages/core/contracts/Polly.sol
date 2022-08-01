/*

       -*%%+++*#+:              .+     --
        =@*     *@*           -#@-  .=#%
        %@.      @@:          .@*    :@:
       -@*       @@.          =@.    #*  :=     --
       #@.      =@#  +*+#:    @=    =@: *=%*    *@
      .@*      :@#.-%-  =@   +%    .@*.+  +@    =#
      *@.    .+%= =%.   =@. :@-    *@     =@:   *-
     :@#---===-  -@-    #@  %%    :@-     -@-  .#
     #@:        .@*    .@+ +@:    ##      -@-  #.
    :@%         *@.    *% .@+    :@.      -@- =:
    #@-         @*    -@. +%  =. %+ .=    -@::=
   :@#          @=   -@- .@-==  +@-+-     -@-*
   *@-          #*  *#.  #@*.  :@@+       =@+
.:=++=:.         ===:    +:    :=.        +=
                                         +-
                                       =+.
                                  +*-=+.

v1

*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PollyModule.sol";

interface IPolly {


  struct ModuleBase {
    string name;
    uint version;
    address implementation;
  }

  struct ModuleInstance {
    string name;
    uint version;
    address location;
  }

  struct Config {
    string name;
    address owner;
    ModuleInstance[] modules;
  }

  function updateModule(address implementation_) external;
  function getModule(string memory name_, uint version_) external view returns(IPolly.ModuleBase memory);
  function getModuleVersion(string memory name_) external view returns(uint);
  function moduleExists(string memory name_, uint version_) external view returns(bool exists_);
  function useModule(uint config_id_, IPolly.ModuleInstance memory mod_) external;
  function useModules(uint config_id_, IPolly.ModuleInstance[] memory mods_) external;
  // function createConfig(string memory name_, IPolly.ModuleInstance[] memory mod_) external;
  // function getConfigsForOwner(address owner_, uint limit_, uint page_) external view returns(uint[] memory);
  // function getConfig(uint config_id_) external view returns(IPolly.Config memory);
  // function isConfigOwner(uint config_id_, address check_) external view returns(bool);
  // function transferConfig(uint config_id_, address to_) external;


}


contract Polly is Ownable {


    /// PROPERTIES ///

    string[] private _module_names;
    mapping(string => mapping(uint => address)) private _modules;
    mapping(string => uint) private _module_versions;

    // uint private _config_id;
    // mapping(uint => IPolly.Config) private _configs;
    // mapping(uint => address) private _config_owners;
    // mapping(address => uint) private _owner_configs;
    // mapping(address => uint[]) private _configs_for_owner;

    //////////////////




    /// EVENTS ///

    event moduleUpdated(
      string indexed name, uint version, address indexed implementation
    );

    event moduleCloned(
      string indexed name, uint version, address location
    );

    // event configCreated(
    //   uint id, string name, address indexed by
    // );

    // event configUpdated(
    //   uint indexed id, string indexed module_name, uint indexed module_version
    // );

    // event configTransferred(
    //   uint indexed id, address indexed from, address indexed to
    // );

    //////////////


    /// @dev restricts access to owner of config
    // modifier onlyConfigOwner(uint config_id_) {
    //   require(isConfigOwner(config_id_, msg.sender), 'NOT_CONFIG_OWNER');
    //   _;
    // }

    /// @dev used when passing multiple modules
    // modifier onlyValidModules(IPolly.ModuleInstance[] memory mods_) {
    //   for(uint i = 0; i < mods_.length; i++){
    //     require(moduleExists(mods_[i].name, mods_[i].version), string(abi.encodePacked('MODULE_DOES_NOT_EXIST: ', mods_[i].name)));
    //   }
    //   _;
    // }


    /// MODULES ///

    /// @dev adds or updates a given module implemenation
    function updateModule(address implementation_) public onlyOwner {

      IPollyModule.ModuleInfo memory info_ = IPollyModule(implementation_).getModuleInfo();

      uint version_ = _module_versions[info_.name]+1;

      IPolly.ModuleBase memory module_ = IPolly.ModuleBase(
        info_.name, version_, implementation_
      );

      _modules[info_.name][version_] = implementation_;
      _module_versions[module_.name] = version_;

      if(version_ == 1)
        _module_names.push(module_.name);

      emit moduleUpdated(module_.name, module_.version, module_.implementation);

    }


    /// @dev retrieves a specific module version base
    function getModule(string memory name_, uint version_) public view returns(IPolly.ModuleBase memory){

      if(version_ < 1)
        version_ = _module_versions[name_];

      return IPolly.ModuleBase(name_, version_, _modules[name_][version_]);

    }


    /// @dev retrieves the most recent version number for a module
    function getModuleVersion(string memory name_) public view returns(uint){
      return _module_versions[name_];
    }


    /// @dev check if a module version exists
    function moduleExists(string memory name_, uint version_) public view returns(bool exists_){
      if(_modules[name_][version_] != address(0))
        exists_ = true;
      return exists_;
    }


    /// @dev clone a given module
    function cloneModule(string memory name_, uint version_) public returns(address) {

      require(moduleExists(name_, version_), string(abi.encodePacked('MODULE_DOES_NOT_EXIST: ', name_)));
      IPollyModule.ModuleInfo memory base_info_ = IPollyModule(_modules[name_][version_]).getModuleInfo();
      require(base_info_.clone, 'MODULE_DOES_NOT_SUPPORT_CLONE');

      address implementation_ = _modules[name_][version_];

      IPollyModule module_ = IPollyModule(Clones.clone(implementation_));
      module_.init(msg.sender);

      emit moduleCloned(name_, version_, address(module_));
      return address(module_);

    }


    function getModules(uint limit_, uint page_) public view returns(IPollyModule.ModuleInfo[] memory){

      if(limit_ < 1 && page_ < 1){
        page_ = 1;
        limit_ = _module_names.length;
      }

      IPollyModule.ModuleInfo[] memory modules_ = new IPollyModule.ModuleInfo[](limit_);
      uint i = 0;
      uint index;
      uint offset = (page_-1)*limit_;
      while(i < limit_ && i < _module_names.length){
        index = i+(offset);
        if(_module_names.length > index){
          modules_[i] = IPollyModule(_modules[_module_names[index]][_module_versions[_module_names[index]]]).getModuleInfo();
        }
        ++i;
      }

      return modules_;

    }


    // function _useModule(uint config_id_, IPolly.ModuleInstance memory mod_) private {

    //   IPolly.ModuleBase memory base_ = getModule(mod_.name, mod_.version);
    //   IPollyModule.ModuleInfo memory base_info_ = IPollyModule(_modules[mod_.name][mod_.version]).getModuleInfo();

    //   // Location is 0 - proceed to attach or clone
    //   if(mod_.location == address(0x00)){
    //     if(base_info_.clone)
    //       _cloneAndAttachModule(config_id_, base_.name, base_.version);
    //     else
    //       _attachModule(config_id_, base_.name, base_.version, base_.implementation);
    //   }
    //   else {
    //     // Reuse - attach module
    //     _attachModule(config_id_, mod_.name, mod_.version, mod_.location);
    //   }

    // }

    // /// @dev add one module to a configuration
    // function useModule(uint config_id_, IPolly.ModuleInstance memory mod_) public onlyConfigOwner(config_id_) {

    //   require(moduleExists(mod_.name, mod_.version), string(abi.encodePacked('MODULE_DOES_NOT_EXIST: ', mod_.name)));
    //   _useModule(config_id_, mod_);

    // }

    // /// @dev add multiple modules to a configuration
    // function useModules(uint config_id_, IPolly.ModuleInstance[] memory mods_) public onlyConfigOwner(config_id_) onlyValidModules(mods_) {

    //   for(uint256 i = 0; i < mods_.length; i++) {
    //     _useModule(config_id_, mods_[i]);
    //   }

    // }



    /// CONFIGS

    // /// @dev create a config with a name
    // function createConfig(string memory name_, IPolly.ModuleInstance[] memory mod_) public returns(uint) {

    //   _config_id++;
    //   _configs[_config_id].name = name_;
    //   _configs[_config_id].owner = msg.sender;
    //   _configs_for_owner[msg.sender].push(_config_id);

    //   useModules(_config_id, mod_);

    //   emit configCreated(_config_id, name_, msg.sender);

    //   return _config_id;

    // }

    // /// @dev retrieve configs for owner
    // function getConfigs(uint limit_, uint page_) public view returns(uint[] memory){

    //   if(limit_ < 1 && page_ < 1){
    //     return _modules;
    //   }

    //   uint[] memory configs_ = new uint[](limit_);
    //   uint i = 0;
    //   uint index;
    //   uint offset = (page_-1)*limit_;
    //   while(i < limit_ && i < _configs_for_owner[owner_].length){
    //     index = i+(offset);
    //     if(_configs_for_owner[owner_].length > index){
    //       configs_[i] = _configs_for_owner[owner_][index];
    //     }
    //     i++;
    //   }

    //   return configs_;

    // }

    // /// @dev get a specific config
    // function getConfig(uint config_id_) public view returns(IPolly.Config memory){
    //   return _configs[config_id_];
    // }

    // /// @dev check if address is config owner
    // function isConfigOwner(uint config_id_, address check_) public view returns(bool){
    //   IPolly.Config memory config_ = getConfig(config_id_);
    //   return (config_.owner == check_);
    // }

    // /// @dev transfer config to another address
    // function transferConfig(uint config_id_, address to_) public onlyConfigOwner(config_id_) {

    //   _configs[config_id_].owner = to_;

    //   uint[] memory configs_ = getConfigsForOwner(msg.sender, 0, 0);
    //   uint[] memory new_configs_ = new uint[](configs_.length -1);
    //   uint ii = 0;
    //   for (uint i = 0; i < configs_.length; i++) {
    //     if(configs_[i] == config_id_){
    //       _configs_for_owner[to_].push(config_id_);
    //     }
    //     else {
    //       new_configs_[ii] = config_id_;
    //       ii++;
    //     }
    //   }

    //   _configs_for_owner[msg.sender] = new_configs_;

    //   emit configTransferred(config_id_, msg.sender, to_);

    // }


}
