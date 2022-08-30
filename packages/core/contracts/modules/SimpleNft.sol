//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../Polly.sol";
import "../PollyAux.sol";


/**
 * @title Nft
 * @notice Nft is a Polly module that allows you to create and manage NFTs.
 */

contract SimpleNft is ERC721, PollyModule {

  uint256 private _id;

  // Token meta
  mapping(id => mapping(string => string)) private _tokenString;
  mapping(id => mapping(string => uint)) private _tokenUint;
  mapping(id => mapping(string => address)) private _tokenAddress;

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

  constructor() ERC721('', '') PollyModule() {

  }


  // Polly
  function moduleInfo() public pure returns (IPollyModule.Info memory) {
    return IPollyModule.Info("GenerativeTokens", false);
  }



  // Meta functions

  /// @dev return string value for token id meta
  /// @param _id token id
  /// @param _key key
  /// @return string value
  function tokenString(uint _id, string _key) public view returns (string) {
    return _tokenString[_id][_key];
  }

  /// @dev return uint value for token id meta
  /// @param _id token id
  /// @param _key key
  /// @return uint value
  function tokenUint(uint _id, string _key) public view returns (uint) {
    return _tokenUint[_id][_key];
  }

  /// @dev return address value for token id meta
  /// @param _id token id
  /// @param _key key
  /// @return address value
  function tokenAddress(uint _id, string _key) public view returns (address) {
    return _tokenAddress[_id][_key];
  }

  /// @dev set string value for token id meta
  /// @param _id token id
  /// @param _key key
  /// @param _value value
  function setTokenString(uint _id, string _key, string _value) public onlyManager {
    _tokenString[_id][_key] = _value;
  }

  /// @dev set uint value for token id meta
  /// @param _id token id
  /// @param _key key
  /// @param _value value
  function setTokenUint(uint _id, string _key, uint _value) public onlyManager {
    _tokenUint[_id][_key] = _value;
  }

  /// @dev set address value for token id meta
  /// @param _id token id
  /// @param _key key
  /// @param _value value
  function setTokenAddress(uint _id, string _key, address _value) public onlyManager {
    _tokenAddress[_id][_key] = _value;
  }


  // Token functions

  function tokenUri() public pure returns (string memory) {

    if(getAddress('aux.tokenUri') != address(0)){
      return SimpleNftAux(getAddress('aux.tokenUri')).tokenUri(id_);
    }
    else
    if(tokenUint(id_, 'tokenUri') > 0){
      return tokenUint(id_, 'tokenUri');
    }
    else {
      return getUint('tokenUri');
    }

  }

  function contractUri() public pure returns (string memory) {
    return "";
  }

  function tokenProps(uint id_) public pure returns (uint, uint, uint) {

    uint price_;
    uint max_;
    bool public_;

    // Price


    return TokenProps(
      _price,
      _max,
      _public
    );

  }

  function mint(){
    tokenProps();
    beforeMint(msg);
    afterMint(msg);
  }


  /// @dev return token max for token id
  /// @param _id token id
  /// @return token max
  function tokenMax(uint id_) public pure returns (uint) {
    if(getAddress('aux.tokenMax') != address(0)){
      return SimpleNftAux(getAddress()).tokenPrice(id_);
    }
    else
    if(tokenUint(id_, 'tokenMax') > 0){
      return tokenUint('tokenMax');
    }
    else {
      return getUint('tokenMax');
    }
  }


  /// @dev return token price for token id
  /// @param _id token id
  /// @return token price
  function tokenPrice(uint id_) public pure returns (uint) {
    if(getAddress('aux.tokenPrice') != address(0)){
      return SimpleNftAux(getAddress('aux.tokenPrice')).tokenPrice(id_);
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
  /// @param _id token id
  /// @return token public
  function tokenPublic(uint id_) public pure returns (bool) {
    if(getAddress('aux.tokenPublic') != address(0)){
      return SimpleNftAux(getAddress('aux.tokenPublic')).tokenPublic(id_);
    }
    else
    if(tokenUint(id_, 'tokenPublic') > 0){
      return tokenUint(id_, 'tokenPublic');
    }
    else {
      return getUint('tokenPublic');
    }

  }


  /// @dev return token recipient for token id
  /// @param _id token id
  /// @return token recipient
  function tokenRecipient(uint id_) public pure returns (address) {
    if(getAddress('aux.tokenRecipient') != address(0)){
      return SimpleNftAux(getAddress('aux.tokenRecipient')).tokenRecipient(id_);
    }
    else
    if(tokenAddress(id_, 'tokenRecipient') != address(0)){
      return tokenAddress(id_, 'tokenRecipient');
    }
    else {
      return getAddress('tokenRecipient');
    }

  }



}


interface SimpleNftAux is PollyModule {

  function beforeMint(uint _uint, msg message_) external virtual;
  function afterMint(uint _uint, msg message_) external virtual;
  function tokenUri(uint _id) public virtual returns (uint);
  function contractUri(uint _id) public virtual returns (string memory);
  function tokenPrice(uint id_) public virtual returns (uint);
  function tokenMax(uint id_) public virtual returns (uint);
  function tokenPublic(uint id_) public virtual returns (uint);
  function tokenRecipient(uint id_) public virtual returns (uint);

}


contract NftConfigurator is PollyConfigurator {

  function info() public pure override returns (string memory, string[] memory, string[] memory) {

    string[] memory inputs_ = new string[](2);
    inputs_[0] = "string.name.the name of the token";
    inputs_[1] = "string.symbol.the symbol of the token";

    string[] memory outputs_ = new string[](1);

    return ("Simple NFT contract to allow minting of NFTs", ["Nft"], ["Nft"]);

  }

  function run(Polly polly_, address for_, PollyConfigurator.Param[] memory) public override returns(PollyConfigurator.Param[] memory){

  }



}
