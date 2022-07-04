//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@polly-os/core/contracts/Polly.sol";
import "hardhat/console.sol";

interface IPollyAux {

  function getHooks() external returns(string[] memory);
  function usesHook(string memory hook_) external view returns(bool);

}


abstract contract PollyAux {

    function getHooks() public view virtual returns(string[] memory hooks_);

    /// @dev check if a given hook is used by this aux
    function usesHook(string memory hook_) public view returns(bool){
        string[] memory hooks_ = getHooks();
        for (uint i = 0; i < hooks_.length; i++) {
            if(keccak256(bytes(hooks_[i])) == keccak256(bytes(hook_)))
                return true;
        }
        return false;
    }


}



interface IPollyAuxHandler is IPollyModule {

  function addAux(address aux_address_) external;
  function removeAux(address remove_) external;
  function setAuxAddress(uint index_, address address_) external;
  function getAuxForHook(string memory name_) external view returns(IPollyAux[] memory);

}


abstract contract PollyAuxHandler is PollyModule {

    address[] private _aux;
    mapping(address => uint) private _aux_index;
    mapping(string => address[]) private _hooks;

    function _addAux(address aux_address_) private {

        // _aux.push(aux_address_);
        // _aux_index[aux_address_] = (_aux.length -1);

        string[] memory hooks_ = IPollyAux(aux_address_).getHooks();
        if(hooks_.length > 0){
          for(uint i = 0; i < hooks_.length; i++){
            _hooks[hooks_[i]].push(aux_address_);
          }
        }

    }

    function addAux(address aux_address_) public onlyRole(MANAGER) {
        _addAux(aux_address_);
    }

    function removeAux(address aux_address_) public onlyRole(MANAGER) {

        address[] memory new_aux_;

        string[] memory aux_hooks_ = IPollyAux(aux_address_).getHooks();
        if(aux_hooks_.length > 0){

          address[] memory saved_auxs_;
          string[] memory new_hooks_;
          string memory hook_;
          uint saved_i_;

          for(uint aux_i_ = 0; aux_i_ < aux_hooks_.length; aux_i_++) {

            hook_ = aux_hooks_[aux_i_]; // Store the name of the current hook;
            saved_auxs_ = _hooks[hook_]; // Loop all saved hooks to create a new entry;
            delete _hooks[hook_]; // Delete all existing hooks;

            saved_i_ = 0;
            while(saved_i_ < saved_auxs_.length){
              if(saved_auxs_[saved_i_] != aux_address_){
                _hooks[hook_].push(saved_auxs_[saved_i_]);
                ++saved_i_;
              }
            }

          }

        }

        // address[] memory new_aux_;
        // uint aux_index_ = _aux_index[remove_];
        // uint ii;
        // for(uint256 i = 0; i < _aux.length; i++) {
        //     if(aux_index_ != i){
        //         new_aux_[ii] = _aux[i];
        //     }
        // }
        // _aux = new_aux_;
        // delete _aux_index[remove_];

    }

    function setAuxAddress(uint index_, address address_) public onlyRole(MANAGER) {
        delete _aux_index[address(_aux[index_])];
        _aux[index_] = address_;
        _aux_index[address_] = index_;
    }

    function getAuxForHook(string memory hook_) public view returns(address[] memory){

        // uint ii = 0;
        // address[100] memory aux_temp_;
        // for(uint256 i = 0; i < _aux.length; i++){
        //     if(IPollyAux(_aux[i]).usesHook(hook_)){
        //         aux_temp_[ii] = _aux[i];
        //         ii++;
        //     }
        // }


        // address[] memory aux_ = new address[](ii);
        // for(uint256 iii = 0; iii < aux_.length; iii++) {
        //     aux_[iii] = aux_temp_[iii];
        // }

        return _hooks[hook_];

    }

}
