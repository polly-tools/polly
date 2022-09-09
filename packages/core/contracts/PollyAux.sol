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

  struct Hook {
    string _name;
    bool _use;
  }

  address internal _parent;

  function hooks() public view virtual returns (Hook[] memory);

}



abstract contract PollyAuxParent {

  address internal _aux;
  mapping(string => bool) internal _aux_hooks;
  bool internal _aux_locked;
  PollyAux.Hook[] internal _aux_registered_hooks;

  function _registerHooks(string[] memory hooks_) internal {
    for(uint i = 0; i < hooks_.length; i++) {
      _aux_registered_hooks[i] = PollyAux.Hook(hooks_[i], false);
    }
  }

  function _setAux(address aux_address_) internal {

    require(_aux_locked == false, 'AUX_LOCKED');

    PollyAux aux_ = PollyAux(aux_address_);
    _aux = aux_address_;
    PollyAux.Hook[] memory aux_hooks_ = aux_.hooks();

    for(uint i = 0; i < aux_hooks_.length; i++) {
      _aux_hooks[aux_hooks_[i]._name] = aux_hooks_[i]._use;
    }

  }

}
