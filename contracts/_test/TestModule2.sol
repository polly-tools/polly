//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "./../Module.sol";

interface ITestModule2 is IModule {

  function setString(string memory string_) external;
  function getString() external view returns(string memory);

}


contract TestModule2 is Module {

    string private _string;

    function getModuleInfo() public view returns(IModule.ModuleInfo memory){
      string memory name_ = 'Test module';
      bool clone_ = true;
      return IModule.ModuleInfo(name_, address(this), clone_);
    }

    function setString(string memory string_) public onlyRole(MANAGER_ROLE){
        _string = string_;
    }

    function getString() public view returns(string memory){
        return _string;
    }

}
