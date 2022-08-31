//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../Polly.sol";
import "../PollyAux.sol";


/**
 * @title Editions
 * @notice Editions is a Polly module that allows you to create and manage editioned collectibles.
 */

contract Editions is ERC1155, PollyModule {

  uint private _id_counter;
  mapping(uint => uint) private _mint_count;

  // Token meta
  mapping(uint => mapping(string => string)) private _tokenString;
  mapping(uint => mapping(string => uint)) private _tokenUint;
  mapping(uint => mapping(string => address)) private _tokenAddress;

  // Struct for token properties returned by tokenProps function
  struct TokenProps {
    uint _price;
    uint _max;
    bool _public;
    address _recipient;
  }

  modifier onlyManager(){
    require(isManager(msg.sender), 'ONLY_MANAGER');
    _;
  }

  constructor() ERC1155('') PollyModule() {
    _setConfigurator(address(new EditionsConfigurator()));
  }


  // Polly
  function moduleInfo() public pure returns (IPollyModule.Info memory) {
    return IPollyModule.Info("GenerativeTokens", false);
  }



  // Meta functions

  /// @dev return string value for token id meta
  /// @param id_ token id
  /// @param key_ key
  /// @return string value
  function tokenString(uint id_, string memory key_) public view returns (string memory) {
    return _tokenString[id_][key_];
  }

  /// @dev return uint value for token id meta
  /// @param id_ token id
  /// @param key_ key
  /// @return uint value
  function tokenUint(uint id_, string memory key_) public view returns (uint) {
    return _tokenUint[id_][key_];
  }

  /// @dev return address value for token id meta
  /// @param id_ token id
  /// @param key_ key
  /// @return address value
  function tokenAddress(uint id_, string memory key_) public view returns (address) {
    return _tokenAddress[id_][key_];
  }


  /// @dev set string value for token id meta
  /// @param id_ token id
  /// @param key_ key
  /// @param _value value
  function setTokenString(uint id_, string memory key_, string memory _value) public onlyManager {
    _tokenString[id_][key_] = _value;
  }

  /// @dev set uint value for token id meta
  /// @param id_ token id
  /// @param key_ key
  /// @param _value value
  function setTokenUint(uint id_, string memory key_, uint _value) public onlyManager {
    _tokenUint[id_][key_] = _value;
  }

  /// @dev set address value for token id meta
  /// @param id_ token id
  /// @param key_ key
  /// @param _value value
  function setTokenAddress(uint id_, string memory key_, address _value) public onlyManager {
    _tokenAddress[id_][key_] = _value;
  }


  // Token functions

  /// @dev get token uri from aux,
  /// @param id_ price of the token

  function tokenUri(uint id_) public view returns (string memory) {

    if(getAddress('aux.tokenUri') != address(0)){
      return EditionsAux(getAddress('aux.tokenUri')).tokenUri(id_);
    }
    else
    if(bytes(tokenString(id_, 'tokenUri')).length > 0){
      return tokenString(id_, 'tokenUri');
    }
    else {
      return getString('tokenUri');
    }

  }

  /// @dev return contract URI
  /// @return string contract URI
  function contractUri() public view returns (string memory) {
    if(getAddress('aux.contractUri') != address(0)){
      return EditionsAux(getAddress('aux.contractUri')).contractUri();
    }
    else {
      return getString('contractUri');
    }
  }



  /// @dev mint token with specific ID
  /// @param id_ token id
  function mint(uint id_, uint amount_) public payable {
    require(getUint('id_type') == 2, 'ID_SPECIFICITY_OFF');
    _mintFor(msg.sender, id_, amount_);
  }


  /// @dev mint token with incremental IDs
  function mint() public payable {
    require(getUint('id_type') == 1, 'ID_AUTO_INCREMENT_OFF');
  }

  function _mintFor(address to_, uint id_, uint amount_) private {

    if(tokenMax() > 0)
      require(_mint_count[id_] <= tokenEditions(id_), 'TOKEN_EDITION_MAX_REACHED');
    require(tokenPrice(id_) == msg.value, 'INVALID_MESSAGE_VALUE');

    if(getAddress('aux.beforeMint') != address(0))
      id_ = EditionsAux(getAddress('aux.beforeMint')).beforeMint(id_, EditionsAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

    if(getUint('id_type') == 1) // Auto-increment IDs
      id_ = _id_counter++;

    _mint(to_, id_, amount_, '');

    if(getAddress('aux.afterMint') != address(0))
      EditionsAux(getAddress('aux.afterMint')).afterMint(id_, EditionsAux.Msg(msg.sender, msg.value, msg.data, msg.sig));

  }


  /// @dev return token max for token id
  /// @return token max
  function tokenMax() public view returns (uint) {
    if(getAddress('aux.tokenMax') != address(0)){
      return EditionsAux(getAddress('aux.tokenMax')).tokenMax();
    }
    else {
      return getUint('tokenMax');
    }
  }

  /// @dev return token max for token id
  /// @return token max
  function tokenEditions(uint id_) public view returns (uint) {
    if(getAddress('aux.tokenEditions') != address(0)){
      return EditionsAux(getAddress('aux.tokenEditions')).tokenEditions(id_);
    }
    else
    if(tokenUint(id_, 'tokenEditions') > 0){
      return tokenUint(id_, 'tokenEditions');
    }
    else {
      return getUint('tokenEditions');
    }
  }



  /// @dev return token price for token id
  /// @param id_ token id
  /// @return token price
  function tokenPrice(uint id_) public view returns (uint) {
    if(getAddress('aux.tokenPrice') != address(0)){
      return EditionsAux(getAddress('aux.tokenPrice')).tokenPrice(id_);
    }
    else
    if(tokenUint(id_, 'tokenPrice') > 0){
      return tokenUint(id_, 'tokenPrice');
    }
    else {
      return getUint('tokenPrice');
    }
  }


  /// @dev return token public for token id
  /// @param id_ token id
  /// @return token public
  function tokenPublic(uint id_) public view returns (bool) {
    if(getAddress('aux.tokenPublic') != address(0)){
      return EditionsAux(getAddress('aux.tokenPublic')).tokenPublic(id_);
    }
    else
    if(tokenUint(id_, 'tokenPublic') == 1){
      return true;
    }
    else
    if(tokenUint(id_, 'tokenPublic') == 2){
      return false;
    }
    else
    if(getUint('tokenPublic') == 1){
      return true;
    }
    else
    if(getUint('tokenPublic') == 2){
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
    if(getAddress('aux.tokenRecipient') != address(0)){
      return EditionsAux(getAddress('aux.tokenRecipient')).tokenRecipient(id_);
    }
    else
    if(tokenAddress(id_, 'tokenRecipient') != address(0)){
      return tokenAddress(id_, 'tokenRecipient');
    }
    else {
      return getAddress('tokenRecipient');
    }

  }


  /// OVERRIDE

  function supportsInterface(bytes4 interface_) public view override(AccessControl, ERC1155) returns (bool) {
    return super.supportsInterface(interface_);
  }


}


abstract contract EditionsAux {

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

  function beforeMint(uint id_, Msg memory msg_) external virtual returns(uint);
  function afterMint(uint id_, Msg memory msg_) external virtual;
  function tokenUri(uint id_) external view virtual returns (string memory);
  function contractUri() external view virtual returns (string memory);
  function tokenPrice(uint id_) external view virtual returns (uint);
  function tokenMax() external view virtual returns (uint);
  function tokenEditions(uint id_) external view virtual returns (uint);
  function tokenPublic(uint id_) external view virtual returns (bool);
  function tokenRecipient(uint id_) external view virtual returns (address);

}


contract EditionsConfigurator is PollyConfigurator {

  function info() public pure override returns (string memory, string[] memory, string[] memory) {

    string[] memory inputs_ = new string[](2);
    inputs_[0] = "string.name.the name of the token";
    inputs_[1] = "string.symbol.the symbol of the token";

    string[] memory outputs_ = new string[](1);
    outputs_[0] = "module.Editions.deployment address of the module";

    return ("Simple NFT contract to allow minting of NFTs", inputs_, outputs_);

  }

  function run(Polly polly_, address for_, PollyConfigurator.Param[] memory) public override returns(PollyConfigurator.Param[] memory){

  }



}
