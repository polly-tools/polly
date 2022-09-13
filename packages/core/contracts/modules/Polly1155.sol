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


contract Polly1155 is PollyToken, ERC1155, PMClone, ReentrancyGuard {


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
  function createToken(PollyToken.Meta[] memory meta_, address[] memory mint_, uint[] memory amounts_) public onlyRole('manager') returns (uint) {

    require(mint_.length == amounts_.length, 'ARRAY_MISMATCH');
    uint id_ = _createToken(meta_);

    for (uint i = 0; i < mint_.length; i++) {
      _mint(mint_[i], id_, amounts_[i], '');
    }

    return id_;
  }


  /// @dev mint a token
  /// @param id_ the id of the token
  /// @param amount_ the amount of tokens to mint
  function mint(uint id_, uint amount_) public payable nonReentrant {

    if(_hasHook('beforeMint1155'))
      getAux('beforeMint1155').beforeMint1155(address(this), id_, amount_, PollyAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

    _mint(msg.sender, id_, amount_, "");
    _supply[id_] += amount_;

    if(_hasHook('afterMint1155'))
      getAux('afterMint1155').afterMint1155(address(this), id_, amount_, PollyAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

  }


  /// @dev get the token uri
  /// @param id_ the id of the token
  function uri(uint id_) public view override returns(string memory) {
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

  function setMetaForId(uint id_, PollyToken.Meta[] memory meta_) public onlyRole('manager') {
    _batchSetMetaForId(id_, meta_);
  }







  /// OVERRIDES
  // function supportsInterface(bytes4 interface_) public view override(AccessControl, ERC1155) returns (bool) {
  //   return super.supportsInterface(interface_);
  // }

}






contract Polly1155Configurator is PollyConfigurator {


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

  function run(Polly polly_, address for_, Polly.Param[] memory inputs_) public override payable virtual returns(Polly.Param[] memory){

    Polly.Param[] memory rparams_ = new Polly.Param[](3);

    // Clone the Polly1155 module
    Polly1155 p1155_ = Polly1155(polly_.cloneModule('Polly1155', 1));
    rparams_[0]._address = address(p1155_);

    // Configure a MetaForIds module
    uint meta_fee_ = polly_.getConfiguratorFee(for_, 'MetaForIds', 1, new Polly.Param[](0));

    Polly.Param[] memory meta_params_ = polly_.configureModule{value: meta_fee_}(
      'MetaForIds', // module name
      1, // version
      new Polly.Param[](0), // No inputs
      false, // Don't store
      '' // No config name
    );

    // Store return param and init the module
    rparams_[1]._address = meta_params_[0]._address;
    MetaForIds meta_ = MetaForIds(meta_params_[0]._address);

    // Connect p1155 to meta
    _grantManager(address(p1155_), address(meta_));
    p1155_.setMetaHandler(meta_params_[0]._address);

    /// Configure a Polly1155Aux module if a valid one is passed to the contract
    if(inputs_.length > 0){

      address[] memory auxs_ = new address[](inputs_.length);

      for(uint i = 0; i < inputs_.length; i++){
        auxs_[i] = inputs_[i]._address;
      }

      p1155_.addAux(auxs_);

    }

    // Transfer to sender
    _transfer(address(p1155_), for_);
    _transfer(address(meta_), for_);


    return rparams_;

  }

}
