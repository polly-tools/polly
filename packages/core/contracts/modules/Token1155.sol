//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "solmate/src/tokens/ERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import './shared/PollyToken.sol';
import '../Polly.sol';
import '../PollyConfigurator.sol';
import '../PollyAux.sol';
import './Json.sol';
import './Meta.sol';


contract Token1155 is PollyToken, ERC1155, PMClone, ReentrancyGuard {


  mapping(uint => uint) private _token_supply;

  string public constant override PMNAME = 'Token1155';
  uint public constant override PMVERSION = 1;


  constructor() ERC1155() PMClone() {
    _setConfigurator(address(new Token1155Configurator()));
  }



  /*

  TOKENS

  */

  /// @dev create a new token
  function createToken(PollyToken.MetaEntry[] memory meta_, address[] memory mint_, uint[] memory amounts_) public returns (uint) {
    _requireRole('manager', msg.sender);
    require(!getMetaHandler().getBool(0, 'auto_create'), 'AUTO_CREATE_ENABLED');

    require(mint_.length == amounts_.length, 'ARRAY_MISMATCH');
    uint id_ = _createToken(meta_);

    for (uint i = 0; i < mint_.length; i++){
      _mintFor(mint_[i], id_, amounts_[i], true, PollyAux.Msg(msg.sender, 0, msg.data, msg.sig));
    }

    return id_;

  }


  /// @dev mint a token
  /// @param id_ the id of the token - pass zero for auto create
  /// @param amount_ the amount of tokens to mint
  function _mintFor(address for_, uint id_, uint amount_, bool pre_, PollyAux.Msg memory msg_) private {

    if(getMetaHandler().getBool(id_, 'auto_create'))
      id_ = _createToken(new PollyToken.MetaEntry[](0));

    if(_hasHook('beforeMint1155'))
      getAux('beforeMint1155').beforeMint1155(address(this), id_, amount_, pre_, msg_);

    _mint(for_, id_, amount_, "");
    _supply[id_] += amount_;

    if(_hasHook('afterMint1155'))
      getAux('afterMint1155').afterMint1155(address(this), id_, amount_, pre_, msg_);

  }



  /// @dev mint a token
  /// @param id_ the id of the token - pass zero for auto create
  /// @param amount_ the amount of tokens to mint
  function mint(uint id_, uint amount_) public payable nonReentrant {
    _mintFor(msg.sender, id_, amount_, false, PollyAux.Msg(msg.sender, msg.value, msg.data, msg.sig));
  }


  /// @dev get the token uri
  /// @param id_ the id of the token
  function uri(uint id_) public view override returns(string memory) {
    return _uri(id_);
  }


  function totalSupply(uint id_) public view returns(uint) {
    return _supply[id_];
  }


  /*
  AUX
  */

  function lockHook(string memory hook_) public {
    _requireRole('admin', msg.sender);
    _aux_locked[hook_] = true;
  }

  function addAux(address[] memory auxs_) public {
    _requireRole('admin', msg.sender);
    _addAux(auxs_);
  }

  function getAux(string memory hook_) public view returns (PollyTokenAux) {
    return PollyTokenAux(_aux_hooks[hook_]);
  }


  /*
  META
  */

  function setMetaHandler(address handler_) public {
    _requireRole('admin', msg.sender);
    _setMetaHandler(handler_);
  }

  function setMetaForId(uint id_, PollyToken.MetaEntry[] memory meta_) public {
    _requireRole('manager', msg.sender);
    _batchSetMetaForId(id_, meta_);
  }



  /// Override
  function supportsInterface(bytes4 interfaceId) public view virtual override(PollyToken, ERC1155) returns (bool){
    return super.supportsInterface(interfaceId);
  }


}






contract Token1155Configurator is PollyConfigurator {


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

  function run(Polly polly_, address for_, Polly.Param[] memory inputs_) public override payable virtual returns(Polly.Param[] memory){

    Polly.Param[] memory rparams_ = new Polly.Param[](3);

    // Clone the Token1155 module
    Token1155 p1155_ = Token1155(polly_.cloneModule('Token1155', 1));
    rparams_[0]._string = 'Token1155';
    rparams_[0]._address = address(p1155_);
    rparams_[0]._uint = 1;

    // Configure a Meta module
    uint meta_fee_ = polly_.getConfiguratorFee(for_, 'Meta', 1, new Polly.Param[](0));

    Polly.Param[] memory meta_params_ = polly_.configureModule{value: meta_fee_}(
      'Meta', // module name
      1, // version
      new Polly.Param[](0), // No inputs
      false, // Don't store
      '' // No config name
    );

    // Store return param and init the module
    rparams_[1] = meta_params_[0];

    Meta meta_ = Meta(meta_params_[0]._address);

    // Connect p1155 to meta
    _grantManager(address(p1155_), address(meta_));
    p1155_.setMetaHandler(meta_params_[0]._address);

    /// Configure a Token1155Aux module if a valid one is passed to the contract
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
