//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "./../PollyModule.sol";

interface ITestModule2 is IPollyModule {

  function setString(string memory string_) external;
  function getString() external view returns(string memory);

}


contract TestModule2 is PollyModule {

    string private _string;

    function getModuleInfo() public view returns(IPollyModule.ModuleInfo memory){
      string memory name_ = 'Test module';
      bool clone_ = true;
      return IPollyModule.ModuleInfo(name_, address(this), clone_);
    }

    function setString(string memory string_) public onlyRole(MANAGER_ROLE){
        _string = string_;
    }

    function getString() public view returns(string memory){
        return _string;
    }

}
