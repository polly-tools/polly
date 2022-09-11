//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "solmate/src/tokens/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '../Polly.sol';
import '../PollyConfigurator.sol';
import '../PollyAux.sol';
import './shared/PollyToken.sol';
import './Json.sol';
import './MetaForIds.sol';

contract Polly721 is PollyToken, ERC721, PMClone, ReentrancyGuard {


  string public constant override PMNAME = 'Polly721';
  uint public constant override PMVERSION = 1;
  string public constant override PMINFO = 'Polly721 | create and mint ERC721 tokens';


  constructor() ERC721("", "") {
    _setConfigurator(address(new Polly721Configurator()));
  }


  /*

  TOKENS

  */

  /// @dev create a new token
  function createToken(PollyToken.Meta[] memory meta_, address mint_) public onlyRole('manager') returns (uint) {

    uint id_ = _createToken(meta_);

    if(mint_ != address(0))
      _mint(mint_, id_);

    return id_;
  }


  /// @dev mint a token
  /// @param id_ the id of the token
  function mint(uint id_) public payable nonReentrant {

    require(_supply[id_] == 0, 'TOKEN_MINTED');

    if(_hasHook('beforeMint721'))
      getAux('beforeMint721').beforeMint721(address(this), id_, PollyAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

    _mint(msg.sender, id_);
    _supply[id_]++;

    if(_hasHook('afterMint721'))
      getAux('afterMint721').afterMint721(address(this), id_, PollyAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

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
    _aux_locked[hook_]= true;
  }

  function setAux(string memory hook_, address aux_) public onlyRole('admin') {
    _setAux(hook_, aux_);
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

  function setMetaForId(uint id_, PollyToken.Meta[] memory meta_) public onlyRole('manager') {
    _batchSetMetaForId(id_, meta_);
  }



  /// OVERRIDES
  // function supportsInterface(bytes4 interface_) public view override(AccessControl, ERC721) returns (bool) {
  //   return super.supportsInterface(interface_);
  // }



}







contract Polly721Configurator is PollyConfigurator, ReentrancyGuard {

  function inputs() public pure override returns (string[] memory) {

    string[] memory inputs_ = new string[](1);
    inputs_[0] = 'address.Aux.address of an optional auxiliary contract';

    return new string[](0);
  }

  function outputs() public pure override returns (string[] memory) {

    string[] memory outputs_ = new string[](3);
    outputs_[0] = 'module.Polly721.address of the Polly721 contract';
    outputs_[1] = 'module.MetaForIds.address of the MetaForIds contract';
    outputs_[2] = 'module.Polly721Aux.address of the Polly721Aux contract';

    return outputs_;

  }

  function run(Polly polly_, address for_, Polly.Param[] memory inputs_) public override payable returns(Polly.Param[] memory){

    Polly.Param[] memory rparams_ = new Polly.Param[](3);

    // Clone the Polly721 module
    Polly721 p721_ = Polly721(polly_.cloneModule('Polly721', 1));
    rparams_[0]._address = address(p721_);

    // Configure a MetaForIds module
    Polly.Param[] memory meta_params_ = polly_.configureModule(
      for_,
      'MetaForIds', // module name
      1, // version
      new Polly.Param[](0), // No inputs
      false, // Don't store
      '' // No config name
    );

    p721_.setMetaHandler(meta_params_[0]._address);
    p721_.grantRole('manager', for_);
    p721_.grantRole('manager', meta_params_[0]._address);

    rparams_[1]._address = meta_params_[0]._address;


    /// Configure a Polly721Aux module if a valid one is passed to the contract
    for(uint i = 0; i < inputs_.length; i++) {
      p721_.setAux(inputs_[i]._string, inputs_[i]._address);
    }

    return rparams_;

  }

}
