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

contract Polly721 is PollyToken, ERC721, PMClone {


  string public constant override PMNAME = 'Polly721';
  uint public constant override PMVERSION = 1;
  string public constant override PMINFO = 'Polly721 | create and allow mint for music tokens';


  constructor() ERC721("", "") {
    _setConfigurator(address(new Polly721Configurator()));
  }


  /*

  TOKENS

  */

  /// @dev create a new token
  function createToken(PollyToken.Meta[] memory meta_) public onlyRole(DEFAULT_ADMIN_ROLE) returns (uint) {
   return _createToken(meta_);
  }


  /// @dev mint a token
  /// @param id_ the id of the token
  function mint(uint id_) public payable {

    if(_aux_hooks['beforeMint721'])
      getAux().beforeMint721(id_, PollyAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

    _mint(msg.sender, id_);

    if(_aux_hooks['afterMint721'])
      getAux().afterMint721(id_, PollyAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

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

  function lockAux() public onlyRole(DEFAULT_ADMIN_ROLE) {
    _aux_locked = true;
  }

  function setAux(address aux_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _setAux(aux_);
  }

  function getAux() public view returns (PollyTokenAux) {
    return PollyTokenAux(_aux);
  }


  /*
  META
  */

  function setMetaHandler(address handler_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _setMetaHandler(handler_);
  }

  function setMetaForId(uint id_, PollyToken.Meta[] memory meta_) public onlyRole(MANAGER) {
    _batchSetMetaForId(id_, meta_);
  }



  /// OVERRIDES
  function supportsInterface(bytes4 interface_) public view override(AccessControl, ERC721) returns (bool) {
    return super.supportsInterface(interface_);
  }



}







contract Polly721Configurator is PollyConfigurator, ReentrancyGuard {

  string public constant override FOR_PMNAME = 'Polly721';
  uint public constant override FOR_PMVERSION = 1;

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

  function run(Polly polly_, address for_, Polly.Param[] memory inputs_) public override returns(Polly.Param[] memory){

    Polly.Param[] memory rparams_ = new Polly.Param[](3);

    // Clone the Polly721 module
    Polly721 mt_ = Polly721(polly_.cloneModule(FOR_PMNAME, FOR_PMVERSION));
    rparams_[0]._address = address(mt_);

    // Configure a MetaForIds module
    Polly.Param[] memory meta_params_ = polly_.configureModule(
      'MetaForIds', // module name
      1, // version
      new Polly.Param[](0), // No inputs
      false, // Don't store
      '' // No config name
    );

    mt_.setMetaHandler(meta_params_[0]._address);
    mt_.grantRole(mt_.MANAGER(), for_);
    mt_.grantRole(mt_.MANAGER(),  meta_params_[0]._address);

    rparams_[1]._address = meta_params_[0]._address;


    /// Configure a Polly721Aux module if a valid one is passed to the contract
    if(inputs_.length > 0 && inputs_[0]._address != address(0)) {
      mt_.setAux(inputs_[0]._address);
      rparams_[2]._address = inputs_[0]._address;
    }

    return rparams_;

  }

}
