//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import './Initializable.sol';
import './Collection.sol';
import './Hooks.sol';
import './Polly.sol';

import "hardhat/console.sol";

interface IAux is IHooks {

  struct AuxInfo{
    string name;
    address location;
    bool clone;
  }

  function init() external;

  function getAuxInfo() external view returns(AuxInfo memory);

  // HOOKS
  function registerHooks(string[] memory hooks_) external;
  function getHooks() external returns(string[] memory);
  function hasHook(string memory hook_) external view returns(bool);

}


abstract contract Aux {

  string[] private _hooks;
  mapping(string => bool) private _hook_names;

  function registerHooks(string[] memory hooks_) public {
    _hooks = hooks_;
    for (uint256 i = 0; i < hooks_.length; i++) {
      _hook_names[hooks_[i]] = true;
    }
  }

  function getHooks() public view returns(string[] memory){
    return _hooks;
  }

  function hasHook(string memory hook_) public view returns(bool){
    return _hook_names[hook_];
  }


}



interface IAuxHandler is IAccessControl, IHooks {

  function init(IPolly.Instance memory instance_, address[] memory aux_) external;
  function getCollectionAddress() external view returns(address);
  function addAux(address aux_address_) external;
  function removeAux(address remove_) external;
  function setAuxAddress(uint index_, address address_) external;
  function getAuxForHook(string memory name_) external view returns(IAux[] memory);

}


contract AuxHandler is AccessControl, Initializable {


  bool _didInit = false;

  IAux[] private _aux;
  mapping(address => uint) private _aux_index;
  mapping(address => bool) private _aux_inited;
  address private _parent_coll;

  /// @dev MANAGER_ROLE allow addresses to use the label contract
  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");


  /// @dev Inits contract for a given address
  function init(IPolly.Instance memory instance_, address[] memory aux_) public {

    super.init();

    _grantRole(DEFAULT_ADMIN_ROLE, instance_.owner);
    _grantRole(MANAGER_ROLE, instance_.owner);

    _grantRole(MANAGER_ROLE, instance_.coll);

    for(uint256 i = 0; i < aux_.length; i++) {
      _addAux(aux_[i]);
    }

    _parent_coll = instance_.coll;

  }

  function getCollectionAddress() public view returns(address){
    return _parent_coll;
  }

  function _addAux(address aux_address_) private {

    IAux aux_ = IAux(aux_address_);
    IAux.AuxInfo memory aux_info_ = aux_.getAuxInfo();

    if(aux_info_.clone){
      aux_ = IAux(Clones.clone(aux_address_));
      if(!_aux_inited[address(aux_)]){
        aux_.init();
        _aux_inited[address(aux_)] = true;
      }
    }

    _aux.push(aux_);
    _aux_index[address(aux_)] = (_aux.length -1);

  }

  function addAux(address aux_address_) public onlyRole(MANAGER_ROLE) {
    _addAux(aux_address_);
  }

  function removeAux(address remove_) public onlyRole(MANAGER_ROLE) {

    IAux[] memory new_aux_;
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

  function setAuxAddress(uint index_, address address_) public onlyRole(MANAGER_ROLE) {
    delete _aux_index[address(_aux[index_])];
    _aux[index_] = IAux(address_);
    _aux_index[address_] = index_;
  }

  function getAuxForHook(string memory name_) public view returns(IAux[] memory){

    uint ii = 0;
    IAux[100] memory aux_temp_;
    for(uint256 i = 0; i < _aux.length; i++){
      if(_aux[i].hasHook(name_)){
        aux_temp_[ii] = _aux[i];
        ii++;
      }
    }


    IAux[] memory aux_ = new IAux[](ii);
    for(uint256 iii = 0; iii < aux_.length; iii++) {
      aux_[iii] = aux_temp_[iii];
    }

    return aux_;

  }


  // ACTIONS

  function actionBeforeMint(uint edition_id_, address sender_) public onlyRole(MANAGER_ROLE) {
    IAux[] memory hooks_ = getAuxForHook('actionBeforeMint');
    for(uint i = 0; i < hooks_.length; i++) {
      hooks_[i].actionBeforeMint(edition_id_, sender_);
    }
  }


  function actionAfterMint(uint edition_id_, address sender_) public onlyRole(MANAGER_ROLE) {
    IAux[] memory hooks_ = getAuxForHook('actionAfterMint');
    for(uint i = 0; i < hooks_.length; i++) {
      hooks_[i].actionAfterMint(edition_id_, sender_);
    }
  }

 function actionBeforeCreateEdition(ICollection.Edition memory edition_, address sender_) public onlyRole(MANAGER_ROLE) {
    IAux[] memory hooks_ = getAuxForHook('actionBeforeCreateEdition');
    for(uint i = 0; i < hooks_.length; i++) {
      hooks_[i].actionBeforeCreateEdition(edition_, sender_);
    }
  }

  function actionAfterCreateEdition(ICollection.Edition memory edition_, address sender_) public onlyRole(MANAGER_ROLE) {
    IAux[] memory hooks_ = getAuxForHook('actionAfterCreateEdition');
    for(uint i = 0; i < hooks_.length; i++) {
      hooks_[i].actionAfterCreateEdition(edition_, sender_);
    }
  }


  // FILTERS

  function filterGetURI(string memory uri_, uint edition_id_) external view returns(string memory){
    IAux[] memory hooks_ = getAuxForHook('filterGetURI');
    for(uint256 i = 0; i < hooks_.length; i++) {
      uri_ = hooks_[i].filterGetURI(uri_, edition_id_);
    }

    return uri_;
  }

  function filterGetArtwork(string memory artwork_, uint edition_id_) external view returns(string memory){
    IAux[] memory hooks_ = getAuxForHook('filterGetArtwork');
    for(uint256 i = 0; i < hooks_.length; i++) {
      artwork_ = hooks_[i].filterGetArtwork(artwork_, edition_id_);
    }

    return artwork_;
  }

  function filterGetAvailable(uint available_, uint edition_id_) external view returns(uint){
    IAux[] memory hooks_ = getAuxForHook('filterGetAvailable');
    for(uint256 i = 0; i < hooks_.length; i++) {
      available_ = hooks_[i].filterGetAvailable(available_, edition_id_);
    }
    return available_;
  }

  function filterIsReleased(bool released_, uint edition_id_) external view returns(bool){
    IAux[] memory hooks_ = getAuxForHook('filterIsReleased');
    for(uint256 i = 0; i < hooks_.length; i++) {
      released_ = hooks_[i].filterIsReleased(released_, edition_id_);
    }
    return released_;
  }

  function filterIsFinalized(bool finalized_, uint edition_id_) external view returns(bool){
    IAux[] memory hooks_ = getAuxForHook('filterIsFinalized');
    for(uint256 i = 0; i < hooks_.length; i++) {
      finalized_ = hooks_[i].filterIsFinalized(finalized_, edition_id_);
    }
    return finalized_;
  }


}
