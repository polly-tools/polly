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
import "./PollyConfigurator.sol";

contract Polly is Ownable {

    /// @dev struct fo an uninstantiated polly module
    struct Module {
      string name;
      uint version;
      address implementation;
      bool clone;
    }

    /// @dev struct for an instantiated polly module
    struct ModuleInstance {
      string name;
      uint version;
      address location;
    }

    /// @dev struct for a configuration of a polly module
    struct Config {
      string name;
      string module;
      PollyConfigurator.Param[] params;
    }


    /// PROPERTIES ///

    string[] private _module_names;
    mapping(string => mapping(uint => address)) private _modules;
    uint private _module_count;
    mapping(string => uint) private _module_versions;
    mapping(address => mapping(uint => Config)) private _configs;
    mapping(address => uint) private _configs_count;

    //////////////////



    /// MODIFIERS ///

    modifier onlyConfigOwner(uint id_) {
      require(_configs_count[msg.sender] >= id_, 'ONLY_CONFIG_OWNER');
      _;
    }


    /// EVENTS ///

    event moduleUpdated(
      string indexed indexedName, string name, uint version, address indexed implementation
    );

    event moduleCloned(
      string indexed indexedName, string name, uint version, address location
    );

    event moduleConfigured(
      string indexedName, string name, uint version, PollyConfigurator.Param[] params
    );


    /// MODULES ///

    /// @dev adds or updates a given module implemenation
    function updateModule(address implementation_) public onlyOwner {

      IPollyModule.Info memory info_ = IPollyModule(implementation_).moduleInfo();

      uint version_ = _module_versions[info_.name]+1;

      _modules[info_.name][version_] = implementation_;
      _module_versions[info_.name] = version_;

      if(version_ == 1)
        _module_names.push(info_.name);

      emit moduleUpdated(info_.name, info_.name, version_, implementation_);

    }


    /// @dev retrieves a specific module version base
    function getModule(string memory name_, uint version_) public view returns(Module memory){

      if(version_ < 1)
        version_ = _module_versions[name_];

      IPollyModule.Info memory module_info_ = IPollyModule(_modules[name_][version_]).moduleInfo();

      return Module(name_, version_, _modules[name_][version_], module_info_.clone);

    }

    /// @dev returns a list of modules available
    function getModules(uint limit_, uint page_, bool ascending_) public view returns(Module[] memory){

      uint count_ = _module_names.length;

      if(limit_ < 1 || limit_ > count_)
        limit_ = count_;

      if(page_ < 1)
        page_ = 1;

      uint i;
      uint index_;


      if(ascending_)
        index_ = page_ == 1 ? 0 : (page_-1)*limit_;
      else
        index_ = page_ == 1 ? count_ : count_ - (limit_*(page_-1));


      if(
        (ascending_ && index_ >= count_)
        ||
        (!ascending_ && index_ == 0)
      )
        return new Module[](0); // no modules available - bail early


      Module[] memory modules_ = new Module[](limit_);

      if(ascending_){

        // ASCENDING
        while(index_ < limit_){
            modules_[i] = getModule(_module_names[index_], 0);
            ++i;
            ++index_;
        }

      }
      else {

        /// DESCENDING
        while(index_ > 0 && i < limit_){
            modules_[i] = getModule(_module_names[index_-1], 0);
            ++i;
            --index_;
        }

      }


      return modules_;

    }


    /// @dev retrieves the most recent version number for a module
    function getLatestModuleVersion(string memory name_) public view returns(uint){
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

      if(version_ == 0)
        version_ = getLatestModuleVersion(name_);

      require(moduleExists(name_, version_), string(abi.encodePacked('INVALID_MODULE_OR_VERSION: ', name_, '@', Strings.toString(version_))));
      IPollyModule.Info memory base_info_ = IPollyModule(_modules[name_][version_]).moduleInfo();
      require(base_info_.clone, 'MODULE_NOT_CLONABLE');

      address implementation_ = _modules[name_][version_];

      IPollyModule module_ = IPollyModule(Clones.clone(implementation_));
      module_.init(msg.sender);

      emit moduleCloned(name_, name_, version_, address(module_));
      return address(module_);

    }


    /// @dev if a module is configurable run the configurator
    function configureModule(string memory name_, uint version_, PollyConfigurator.Param[] memory params_, bool store_, string memory config_name_) public returns(PollyConfigurator.Param[] memory rparams_) {

      if(version_ == 0)
        version_ = getLatestModuleVersion(name_);

      require(moduleExists(name_, version_), string(abi.encodePacked('INVALID_MODULE_OR_VERSION: ', name_, '@', Strings.toString(version_))));

      Module memory module_ = getModule(name_, version_);
      address configurator_ = IPollyModule(module_.implementation).configurator();
      require(configurator_ != address(0), 'NO_MODULE_CONFIGURATOR');

      PollyConfigurator config_ = PollyConfigurator(configurator_);
      rparams_ = config_.run(this, msg.sender, params_);

      uint new_count_ = _configs_count[msg.sender] + 1;
      if(store_){

        _configs[msg.sender][new_count_].name = config_name_;
        _configs[msg.sender][new_count_].module = name_;

        for (uint i = 0; i < rparams_.length; i++) {
          _configs[msg.sender][new_count_].params.push(rparams_[i]);
        }
        ++_configs_count[msg.sender];
      }


      emit moduleConfigured(name_, name_, version_, rparams_);
      return rparams_;

    }

    /// @dev retrieves the stored configurations for a given address
    function getConfigsForAddress(address address_, uint limit_, uint page_, bool ascending_) public view returns(Config[] memory){

      uint count_ = _configs_count[address_];

      if(limit_ < 1 || limit_ > count_)
        limit_ = count_;

      if(page_ < 1)
        page_ = 1;

      uint i;
      uint id_;

      if(ascending_)
        id_ = page_ == 1 ? 1 : ((page_-1)*limit_)+1;
      else
        id_ = page_ == 1 ? count_ : count_ - (limit_*(page_-1));


      if(
        (ascending_ && id_ >= count_)
        ||
        (!ascending_ && id_ == 0)
      )
        return new Config[](0); // no modules available - bail early


      Config[] memory configs_ = new Config[](limit_);


      if(ascending_){

        // ASCENDING
        while(id_ <= count_ && i < limit_){
            configs_[i] = _configs[address_][id_];
            ++i;
            ++id_;
        }

      }
      else {

        /// DESCENDING
        while(id_ > 0 && i < limit_){
            configs_[i] = _configs[address_][id_];
            ++i;
            --id_;
        }

      }

      return configs_;

    }


    /// @dev change the name of a config
    function changeConfigName(uint id_, string memory name_) public onlyConfigOwner(id_) {
      require(id_ > 0 && id_ <= _configs_count[msg.sender], 'INVALID_CONFIG_ID');
      _configs[msg.sender][id_].name = name_;
    }


}
