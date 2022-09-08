//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../Polly.sol";
import "../PollyAux.sol";
import "../modules/MetaForIds.sol";


/**
 * @title Nft
 * @notice Nft is a Polly module that allows you to create and manage NFTs.
 */

contract Nft is ERC721, PMCloneKeystore {

  uint private _id_counter;
  uint private _mint_count;

  string public constant override PMNAME = "Nft";
  uint public constant override PMVERSION = 1;
  string public constant override PMINFO = "basic ERC721 NFT contract";


  modifier onlyManager(){
    require(isManager(msg.sender), 'ONLY_MANAGER');
    _;
  }

  constructor() ERC721('', '') PMCloneKeystore() {
    _setConfigurator(address(new NftConfigurator()));
  }

  function _meta() private view returns(MetaForIds){
    return MetaForIds(get('meta')._address);
  }

  // Token functions

  /// @dev get token uri from aux,
  /// @param id_ price of the token

  function tokenUri(uint id_) public view returns (string memory) {

    if(get('aux.tokenUri')._address != address(0)){
      return NftAux(get('aux.tokenUri')._address).tokenUri(id_);
    }
    else
    if(bytes(_meta().getString(id_, 'tokenUri')).length > 0){
      return _meta().getString(id_, 'tokenUri');
    }
    else {
      return get('tokenUri')._string;
    }

  }

  /// @dev return contract URI
  /// @return string contract URI
  function contractUri() public view returns (string memory) {
    if(get('aux.contractUri')._address != address(0)){
      return NftAux(get('aux.contractUri')._address).contractUri();
    }
    else {
      return get('contractUri')._string;
    }
  }



  /// @dev mint token with specific ID
  /// @param id_ token id
  function mint(uint id_) public payable {
    require(get('id_type')._uint == 2, 'ID_SPECIFICITY_OFF');
    _mintFor(msg.sender, id_);
  }


  /// @dev mint token with incremental IDs
  function mint() public payable {
    require(get('id_type')._uint == 1, 'ID_AUTO_INCREMENT_OFF');
  }

  function _mintFor(address to_, uint id_) private {

    if(tokenMax() > 0)
      require(_mint_count <= tokenMax(), 'TOKEN_MAX_REACHED');
    require(tokenPrice(id_) == msg.value, 'INVALID_MESSAGE_VALUE');

    if(get('aux.beforeMint')._address != address(0))
      id_ = NftAux(get('aux.beforeMint')._address).beforeMint(id_, NftAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

    if(get('id_type')._uint == 1) // Auto-increment IDs
      id_ = _id_counter++;

    _mint(to_, id_);

    if(get('aux.afterMint')._address != address(0))
      NftAux(get('aux.afterMint')._address).afterMint(id_, NftAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

  }


  /// @dev return token max for token id
  /// @return token max
  function tokenMax() public view returns (uint) {
    if(get('aux.tokenMax')._address != address(0)){
      return NftAux(get('aux.tokenMax')._address).tokenMax();
    }
    else {
      return get('tokenMax')._uint;
    }
  }


  /// @dev return token price for token id
  /// @param id_ token id
  /// @return token price
  function tokenPrice(uint id_) public view returns (uint) {
    if(get('aux.tokenPrice')._address != address(0)){
      return NftAux(get('aux.tokenPrice')._address).tokenPrice(id_);
    }
    else
    if(_meta().getUint(id_, 'tokenPrice') > 0){
      return _meta().getUint(id_, 'tokenPrice');
    }
    else {
      return get('tokenPrice')._uint;
    }
  }


  /// @dev return token public for token id
  /// @param id_ token id
  /// @return token public
  function tokenPublic(uint id_) public view returns (bool) {

    if(get('aux.tokenPublic')._address != address(0)){
      return NftAux(get('aux.tokenPublic')._address).tokenPublic(id_);
    }
    else
    if(_meta().getUint(id_, 'tokenPublic') == 1){
      return true;
    }
    else
    if(_meta().getUint(id_, 'tokenPublic') == 2){
      return false;
    }
    else
    if(get('tokenPublic')._uint == 1){
      return true;
    }
    else
    if(get('tokenPublic')._uint == 2){
      return false;
    }
    else {
      return false;
    }

  }


  /// @dev return token recipient for token id
  /// @param id_ token id
  /// @return token recipient
  function tokenRecipient(uint id_) public view returns (address) {
    if(get('aux.tokenRecipient')._address != address(0)){
      return NftAux(get('aux.tokenRecipient')._address).tokenRecipient(id_);
    }
    else
    if(_meta().getAddress(id_, 'tokenRecipient') != address(0)){
      return _meta().getAddress(id_, 'tokenRecipient');
    }
    else {
      return get('tokenRecipient')._address;
    }

  }


  function name() public view override returns (string memory) {
    return get('name')._string;
  }


  function symbol() public view override returns (string memory) {
    return get('symbol')._string;
  }


  /// OVERRIDE

  function supportsInterface(bytes4 interface_) public view override(AccessControl, ERC721) returns (bool) {
    return super.supportsInterface(interface_);
  }


}


abstract contract NftAux {

  struct Msg {
    address _sender;
    uint _value;
    bytes _data;
    bytes4 _sig;
  }

  address private _parent;

  modifier onlyParent(){
    require(_parent == msg.sender, 'ONLY_PARENT');
    _;
  }

  function name() public view virtual returns (string memory);
  function symbol() public view virtual returns (string memory);
  function beforeMint(uint id_, Msg memory msg_) external virtual returns(uint);
  function afterMint(uint id_, Msg memory msg_) external virtual;
  function tokenUri(uint id_) external view virtual returns (string memory);
  function contractUri() external view virtual returns (string memory);
  function tokenPrice(uint id_) external view virtual returns (uint);
  function tokenMax() external view virtual returns (uint);
  function tokenPublic(uint id_) external view virtual returns (bool);
  function tokenRecipient(uint id_) external view virtual returns (address);

}


contract NftConfigurator is PollyConfigurator {


  string public constant override FOR_PMNAME = 'Nft';
  uint public constant override FOR_PMVERSION = 1;

  function inputs() public pure override returns (string[] memory) {
    string[] memory inputs_ = new string[](3);
    inputs_[0] = "string.Name.the name of the token";
    inputs_[1] = "string.Symbol.the symbol of the token";
    inputs_[2] = "bool.Meta for IDs.should a MetaForId module be included?";
    return inputs_;
  }

  function outputs() public pure override returns (string[] memory) {
    string[] memory outputs_ = new string[](2);
    outputs_[0] = "module.Nft.deployment address of the module";
    outputs_[1] = "module.MetaForId.deployment address of the MetaForId module if there is one";
    return outputs_;
  }

  function run(Polly polly_, address for_, Polly.Param[] memory inputs_) public override returns(Polly.Param[] memory){

    Polly.Param[] memory rparams_ = new Polly.Param[](2);

    // Clone the Nft module
    PMCloneKeystore nft_ = PMCloneKeystore(polly_.cloneModule(FOR_PMNAME, FOR_PMVERSION));
    if(inputs_.length > 0)
      nft_.set(Polly.ParamType.STRING, 'name', inputs_[0]);
    if(inputs_.length > 1)
      nft_.set(Polly.ParamType.STRING, 'symbol', inputs_[1]);


    if(inputs_.length > 2 && inputs_[2]._bool){

      Polly.Param[] memory meta_params_ = polly_.configureModule(
        'MetaForIds', // module name
        1, // version
        new Polly.Param[](0), // No inputs
        false, // Don't store
        '' // No config name
      );

      nft_.set(Polly.ParamType.ADDRESS, 'meta', meta_params_[0]);
      nft_.grantRole(nft_.MANAGER(), for_);
      nft_.grantRole(nft_.MANAGER(),  meta_params_[0]._address);

    }


    return rparams_;


  }



}
