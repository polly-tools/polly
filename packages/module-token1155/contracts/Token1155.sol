//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "solmate/src/tokens/ERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@polly-tools/polly-token/contracts/PollyToken.sol';
import '@polly-tools/core/contracts/Polly.sol';
import '@polly-tools/core/contracts/PollyConfigurator.sol';
import '@polly-tools/core/contracts/PollyAux.sol';
import '@polly-tools/module-meta/contracts/Meta.sol';

contract Token1155 is PollyToken, ERC1155, ReentrancyGuard {


  string public constant override PMNAME = 'Token1155';
  uint public constant override PMVERSION = 1;

  mapping(uint => uint) internal _supply;


  constructor() ERC1155() PMClone() {
    _setConfigurator(address(new Token1155Configurator()));
  }


  /*
  TOKENS
  */

  /// @dev create a new token
  function createToken(PollyToken.MetaEntry[] memory meta_, address[] memory mint_, uint[] memory amounts_) public returns (uint) {

    _requireRole('manager', msg.sender);

    require(mint_.length == amounts_.length);
    uint id_ = _createToken(meta_);

    for (uint i = 0; i < mint_.length; i++){
      _mintFor(mint_[i], id_, amounts_[i], true);
    }

    return id_;

  }



  /// @dev mint a token
  /// @param id_ the id of the token - pass zero for auto create
  /// @param amount_ the amount of tokens to mint
  function _mintFor(address for_, uint id_, uint amount_, bool pre_) private {

    address hook_ = getMetaHandler().getAddress(0, 'action:beforeMint1155');
    if(hook_ != address(0))
      _call(hook_, abi.encodeWithSignature('beforeMint1155(address,uint256,uint256,bool,(address,uint256,bytes,bytes4))', for_, id_, amount_, pre_));


    _mint(for_, id_, amount_, "");
    _supply[id_] += amount_;

    hook_ = getMetaHandler().getAddress(0, 'action:afterMint1155');
    if(hook_ != address(0))
      _call(hook_, abi.encodeWithSignature('afterMint1155(address,uint256,uint256,bool,(address,uint256,bytes,bytes4))', for_, id_, amount_, pre_));

  }



  /// @dev mint a token
  /// @param id_ the id of the token - pass zero for auto create
  /// @param amount_ the amount of tokens to mint
  function mint(uint id_, uint amount_) public payable nonReentrant {

    _mintFor(msg.sender, id_, amount_, false);
    _postMintTransfer(id_, msg.value);

  }



  /// @dev get the token uri
  /// @param id_ the id of the token
  function uri(uint id_) public view override returns(string memory) {
    return _tokenUri(id_);
  }


  function totalSupply(uint id_) public view returns(uint) {
    return _supply[id_];
  }



  /// Override
  function supportsInterface(bytes4 interfaceId) public view virtual override(PollyToken, ERC1155) returns (bool){
    return super.supportsInterface(interfaceId);
  }

  function setApprovalForAll(address operator, bool approved) public override {
    address hook_ = getHookAddress('action:beforeSetApprovalForAll');
    if(hook_ != address(0))
      _call(hook_, abi.encodeWithSignature('beforeSetApprovalForAll(address,bool)', operator, approved));
    super.setApprovalForAll(operator, approved);
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes calldata data) public override {
    address hook_ = getHookAddress('action:beforeSafeTransferFrom');
    if(hook_ != address(0))
      _call(hook_, abi.encodeWithSignature('beforeSafeTransferFrom(address,address,uint256,uint256,bytes)', from, to, tokenId, amount, data));
    super.safeTransferFrom(from, to, tokenId, amount, data);
  }

  function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) public virtual override {
    address hook_ = getHookAddress('action:beforeSafeBatchTransferFrom');
    if(hook_ != address(0))
      _call(hook_, abi.encodeWithSignature('beforeSafeBatchTransferFrom(address,address,uint256[],uint256[],bytes)', from, to, ids, amounts, data));
    super.safeBatchTransferFrom(from, to, ids, amounts, data);
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
    Token1155 token_ = Token1155(polly_.cloneModule('Token1155', 1));
    rparams_[0]._string = 'Token1155';
    rparams_[0]._address = address(token_);
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
    _grantManager(address(token_), address(meta_));
    token_.setMetaHandler(meta_params_[0]._address);

    /// Configure a Token1155Aux module if a valid one is passed to the contract
    if(inputs_.length > 0){
      for(uint i = 0; i < inputs_.length; i++){
        token_.registerAux(inputs_[i]._address);
      }
    }

    // Transfer to sender
    _transfer(address(token_), for_);
    _transfer(address(meta_), for_);


    return rparams_;

  }

}
