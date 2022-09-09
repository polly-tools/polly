//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "solmate/src/tokens/ERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import './shared/PollyToken.sol';
import '../Polly.sol';
import '../PollyConfigurator.sol';
import '../PollyAux.sol';
import './Json.sol';
import './MetaForIds.sol';


contract Polly1155 is PollyToken, ERC1155, PMCloneKeystore {


  mapping(uint => uint) private _token_supply;


  string public constant override PMNAME = 'Polly1155';
  uint public constant override PMVERSION = 1;
  string public constant override PMINFO = 'Polly1155 | create and allow mint for music tokens';


  constructor() ERC1155() {
    _setConfigurator(address(new Polly1155Configurator()));
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
  /// @param amount_ the amount of tokens to mint
  function mint(uint id_, uint amount_) public payable {

    if(_aux_hooks['beforeMint1155'])
      getAux().beforeMint1155(id_, amount_, PollyAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

    _mint(msg.sender, id_, amount_, "");

    if(_aux_hooks['afterMint1155'])
      getAux().afterMint1155(id_, amount_, PollyAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

  }


  function safeTransferFrom(
    address from_,
    address to_,
    uint256 id_,
    uint256 amount_,
    bytes calldata data_
  ) public override {

    super.safeTransferFrom(from_, to_, id_, amount_, data_);
    _token_supply[id_] = _token_supply[id_] + amount_;

  }

  function safeBatchTransferFrom(
      address from_,
      address to_,
      uint256[] calldata ids_,
      uint256[] calldata amounts_,
      bytes calldata data_
  ) public override {

    super.safeBatchTransferFrom(from_, to_, ids_, amounts_, data_);

    uint id_;
    for (uint i = 0; i < ids_.length;) {

      id_ = ids_[i];
      _token_supply[id_] = _token_supply[id_] + amounts_[i];

      unchecked {
        ++i;
      }

    }

  }



  function totalSupply(uint id_) public view returns (uint) {
    return _token_supply[id_];
  }


  /// @dev get the token uri
  /// @param id_ the id of the token
  function uri(uint id_) public view override returns(string memory) {
    _uri(id_);
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
  function supportsInterface(bytes4 interface_) public view override(AccessControl, ERC1155) returns (bool) {
    return super.supportsInterface(interface_);
  }

}






contract Polly1155Configurator is PollyConfigurator {


  string public constant override FOR_PMNAME = 'Polly1155';
  uint public constant override FOR_PMVERSION = 1;


  function inputs() public pure override virtual returns (string[] memory) {

    string[] memory inputs_ = new string[](1);
    inputs_[0] = 'address.Aux.address of an optional auxiliary contract';

    return new string[](0);
  }

  function outputs() public pure override virtual returns (string[] memory) {

    string[] memory outputs_ = new string[](3);
    outputs_[0] = 'module.Polly1155.address of the Polly1155 contract';
    outputs_[1] = 'module.MetaForIds.address of the MetaForIds contract';
    outputs_[2] = 'module.Polly1155Aux.address of the Polly1155Aux contract';

    return outputs_;

  }

  function run(Polly polly_, address for_, Polly.Param[] memory inputs_) public override virtual returns(Polly.Param[] memory){

    Polly.Param[] memory rparams_ = new Polly.Param[](3);

    // Clone the Polly1155 module
    Polly1155 mt_ = Polly1155(polly_.cloneModule('Polly1155', 1));
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


    /// Configure a Polly1155Aux module if a valid one is passed to the contract
    if(inputs_.length > 0 && inputs_[0]._address != address(0)) {
      mt_.setAux(inputs_[0]._address);
      rparams_[2]._address = inputs_[0]._address;
    }

    return rparams_;

  }

}
