//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@polly-os/core/contracts/Polly.sol";

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
    mapping(address => bool) private _aux_inited;


    function _addAux(address aux_address_) private {
        _aux.push(aux_address_);
        _aux_index[aux_address_] = (_aux.length -1);
    }

    function addAux(address aux_address_) public onlyRole(MANAGER) {
        _addAux(aux_address_);
    }

    function removeAux(address remove_) public onlyRole(MANAGER) {

        address[] memory new_aux_;
        uint aux_index_ = _aux_index[remove_];
        uint ii;
        for(uint256 i = 0; i < _aux.length; i++) {
            if(aux_index_ != i){
                new_aux_[ii] = _aux[i];
            }
        }
        _aux = new_aux_;
        delete _aux_index[remove_];

    }

    function setAuxAddress(uint index_, address address_) public onlyRole(MANAGER) {
        delete _aux_index[address(_aux[index_])];
        _aux[index_] = address_;
        _aux_index[address_] = index_;
    }

    function getAuxForHook(string memory name_) public view returns(address[] memory){

        uint ii = 0;
        address[100] memory aux_temp_;
        for(uint256 i = 0; i < _aux.length; i++){
            if(IPollyAux(_aux[i]).usesHook(name_)){
                aux_temp_[ii] = _aux[i];
                ii++;
            }
        }


        address[] memory aux_ = new address[](ii);
        for(uint256 iii = 0; iii < aux_.length; iii++) {
            aux_[iii] = aux_temp_[iii];
        }

        return aux_;

    }

}
