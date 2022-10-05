//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "./Polly.sol";

abstract contract PollyAux {

  struct Msg {
    address _sender;
    uint _value;
    bytes _data;
    bytes4 _sig;
  }

  address internal _parent;

  function hooks() public view virtual returns (string[] memory);

}



abstract contract PollyAuxParent {

  mapping(string => address) internal _aux_hooks;
  mapping(string => bool) internal _aux_locked;


  function _lockHook(string memory hook_) internal {
    _aux_locked[hook_] = true;
  }

  function _addAux(address[] memory auxs_) internal {

    PollyAux aux_;
    string[] memory hooks_;
    address aux_address_;
    uint i = 0;
    while(i < auxs_.length) {
      aux_address_ = auxs_[i];
      if(aux_address_ != address(0)){
        aux_ = PollyAux(aux_address_);
        hooks_ = aux_.hooks();
        for(uint j = 0; j < hooks_.length; j++) {
          if(!_aux_locked[hooks_[j]])
            _aux_hooks[hooks_[j]] = address(aux_);
        }
      }
      ++i;
    }
  }

  function _setAux(string memory hook_, address aux_) internal {
    require(_aux_locked[hook_] == false, 'AUX_LOCKED');
    _aux_hooks[hook_] = aux_;
  }

  function _hasHook(string memory hook_) internal view returns (bool) {
    return _aux_hooks[hook_] != address(0);
  }

  function addressForHook(string memory hook_) public view returns (address) {
    return _aux_hooks[hook_];
  }

}
