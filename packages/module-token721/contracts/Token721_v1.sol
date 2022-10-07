//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "solmate/src/tokens/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@polly-os/core/contracts/Polly.sol';
import '@polly-os/core/contracts/PollyConfigurator.sol';
import '@polly-os/core/contracts/PollyAux.sol';
import '@polly-os/module-polly-token/contracts/PollyToken_v1.sol';
import '@polly-os/module-json/contracts/Json_v1.sol';
import '@polly-os/module-meta/contracts/Meta_v1.sol';

contract Token721 is PollyToken, ERC721, PMClone, ReentrancyGuard {


  string public constant override PMNAME = 'Token721';
  uint public constant override PMVERSION = 1;


  constructor() ERC721("", "") {
    _setConfigurator(address(new Token721Configurator()));
  }


  /*

  TOKENS

  */

  /// @dev create a new token
  function createToken(PollyToken.MetaEntry[] memory meta_, address[] memory mint_) public onlyRole('manager') returns (uint) {

    uint id_ = _createToken(meta_);

    for (uint i = 0; i < mint_.length; i++){
      _mintFor(mint_[i], id_, true, PollyAux.Msg(msg.sender, 0, msg.data, msg.sig));
    }

    return id_;

  }

  /// @dev mint a token
  /// @param id_ the id of the token
  function _mintFor(address for_, uint id_, bool pre_, PollyAux.Msg memory msg_) private {

    if(_hasHook('beforeMint721'))
      getAux('beforeMint721').beforeMint721(address(this), id_, pre_, msg_);

    _mint(for_, id_);
    _supply[id_] = 1;

    if(_hasHook('afterMint721'))
      getAux('afterMint721').afterMint721(address(this), id_, pre_, msg_);

  }




  /// @dev mint a token
  /// @param id_ the id of the token
  function mint(uint id_) public payable nonReentrant {
    _mintFor(msg.sender, id_, false, PollyAux.Msg(msg.sender, msg.value, msg.data, msg.sig));
  }


  function totalSupply() public view returns (uint) {
    return _token_count;
  }

  /// @dev get the token uri
  /// @param id_ the id of the token
  function tokenURI(uint id_) public view override returns(string memory) {
    return _uri(id_);
  }


  /*
  AUX
  */

  function lockHook(string memory hook_) public onlyRole('admin') {
    _aux_locked[hook_] = true;
  }

  function addAux(address[] memory auxs_) public onlyRole('admin') {
    _addAux(auxs_);
  }

  function getAux(string memory hook_) public view returns (PollyTokenAux) {
    return PollyTokenAux(_aux_hooks[hook_]);
  }


  /*
  META
  */

  function setMetaHandler(address handler_) public onlyRole('admin') {
    _setMetaHandler(handler_);
  }

  function setMetaForId(uint id_, PollyToken.MetaEntry[] memory meta_) public onlyRole('manager') {
    _batchSetMetaForId(id_, meta_);
  }


  /// Override
  function supportsInterface(bytes4 interfaceId) public view virtual override(PollyToken, ERC721) returns (bool){
      return super.supportsInterface(interfaceId);
  }



}







contract Token721Configurator is PollyConfigurator, ReentrancyGuard {

  function inputs() public pure override virtual returns (string[] memory) {

    string[] memory inputs_ = new string[](1);
    inputs_[0] = '...address || Aux addresses || addresses of the aux contracts to attach';
    return inputs_;
  }

  function outputs() public pure override virtual returns (string[] memory) {

    string[] memory outputs_ = new string[](2);

    outputs_[0] = 'module || Token1155 || the main Token1155 module address';
    outputs_[1] = 'module || Meta || the meta handler address';

    return outputs_;

  }

  function run(Polly polly_, address for_, Polly.Param[] memory inputs_) public override payable returns(Polly.Param[] memory){

    Polly.Param[] memory rparams_ = new Polly.Param[](3);

    // Clone the Token721 module
    Token721 p721_ = Token721(polly_.cloneModule('Token721', 1));
    rparams_[0]._string = 'Token721';
    rparams_[0]._address = address(p721_);
    rparams_[0]._uint = 1;

    // Configure a Meta module
    Polly.Param[] memory meta_params_ = polly_.configureModule(
      'Meta', // module name
      1, // version
      new Polly.Param[](0), // No inputs
      false, // Don't store
      '' // No config name
    );

    p721_.setMetaHandler(meta_params_[0]._address);
    p721_.grantRole('manager', meta_params_[0]._address);

    rparams_[1] = meta_params_[0];


    /// Configure a Token1155Aux module if a valid one is passed to the contract
    if(inputs_.length > 0){

      address[] memory auxs_ = new address[](inputs_.length);

      for(uint i = 0; i < inputs_.length; i++){
        auxs_[i] = inputs_[i]._address;
      }

      p721_.addAux(auxs_);

    }

    // Transfer to sender
    _transfer(address(p721_), for_);
    _transfer(meta_params_[0]._address, for_);

    return rparams_;

  }

}
