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


  struct Module {
    string name;
    uint version;
    address implementation;
    bool clone;
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
  function getModule(string memory name_, uint version_) external view returns(IPolly.Module memory);
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

    //////////////////




    /// EVENTS ///

    event moduleUpdated(
      string indexed name, uint version, address indexed implementation
    );

    event moduleCloned(
      string indexed name, uint version, address location
    );


    /// MODULES ///

    /// @dev adds or updates a given module implemenation
    function updateModule(address implementation_) public onlyOwner {

      IPollyModule.Info memory info_ = IPollyModule(implementation_).getInfo();

      uint version_ = _module_versions[info_.name]+1;

      _modules[info_.name][version_] = implementation_;
      _module_versions[info_.name] = version_;

      if(version_ == 1)
        _module_names.push(info_.name);

      emit moduleUpdated(info_.name, version_, implementation_);

    }


    /// @dev retrieves a specific module version base
    function getModule(string memory name_, uint version_) public view returns(IPolly.Module memory){

      if(version_ < 1)
        version_ = _module_versions[name_];

      IPollyModule.Info memory module_info_ = IPollyModule(_modules[name_][version_]).getInfo();

      return IPolly.Module(name_, version_, _modules[name_][version_], module_info_.clone);

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
      IPollyModule.Info memory base_info_ = IPollyModule(_modules[name_][version_]).getInfo();
      require(base_info_.clone, 'MODULE_DOES_NOT_SUPPORT_CLONE');

      address implementation_ = _modules[name_][version_];

      IPollyModule module_ = IPollyModule(Clones.clone(implementation_));
      module_.init(msg.sender);

      emit moduleCloned(name_, version_, address(module_));
      return address(module_);

    }


    function getModules(uint limit_, uint page_) public view returns(IPolly.Module[] memory){

      if(limit_ < 1 && page_ < 1){
        page_ = 1;
        limit_ = _module_names.length;
      }

      IPolly.Module[] memory modules_ = new IPolly.Module[](limit_);
      IPollyModule.Info memory module_info_;

      uint i = 0;
      uint index;
      uint offset = (page_-1)*limit_;
      while(i < limit_ && i < _module_names.length){
        index = i+(offset);
        if(_module_names.length > index){
          module_info_ = IPollyModule(_modules[_module_names[index]][_module_versions[_module_names[index]]]).getInfo();
          modules_[i] = IPolly.Module(
            _module_names[index],
            _module_versions[_module_names[index]],
            _modules[_module_names[index]][_module_versions[_module_names[index]]],
            module_info_.clone
          );
        }
        ++i;
      }

      return modules_;

    }

}
