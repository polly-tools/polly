//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import '@polly-os/core/contracts/Polly.sol';
import '@polly-os/core/contracts/PollyConfigurator.sol';
import '@polly-os/polly-token/contracts/PollyToken_v1.sol';
import '@polly-os/module-royalty-info/contracts/RoyaltyInfo_v1.sol';
import '@polly-os/module-token1155/contracts/Token1155_v1.sol';
import '@polly-os/module-token721/contracts/Token721_v1.sol';
import '@polly-os/module-token-utils/contracts/TokenUtils_v1.sol';
import 'base64-sol/base64.sol';


contract MusicToken_v1 is PMReadOnly, PollyTokenAux_v1 {

  struct MetaItem {
    string _key;
    Json_v1.Type _type;
  }

  string public constant override PMNAME = "MusicToken";
  uint256 public constant override PMVERSION = 1;

  MusicTokenSchema private _schema;
  Json_v1 private _json;
  TokenUtils_v1 private _utils;

  string[] private _hooks = [
    "beforeCreateToken",
    "beforeMint1155",
    "beforeMint721",
    "tokenURI"
  ];

  constructor(address polly_address_) {

    _setConfigurator(address(new MusicTokenConfigurator()));

    Polly polly_ = Polly(polly_address_);

    _json = Json_v1(
      polly_
      .getModule('Json', 1)
      .implementation
    );

    _utils = TokenUtils_v1(
      polly_
      .getModule('TokenUtils', 1)
      .implementation
    );


    _schema = new MusicTokenSchema();
  }


  function _stringIsEmpty(string memory string_) private pure returns (bool) {
    return keccak256(abi.encodePacked(string_)) == keccak256(abi.encodePacked(''));
  }


  function hooks() public view override returns (string[] memory) {
    return _hooks;
  }


  /// @dev internal function to run on beforeMint1155 and beforeMint721
  function _beforeMint(address parent_, uint id_, bool pre_, PollyAux.Msg memory msg_) private view {
    require(PollyToken_v1(parent_).tokenExists(id_), 'TOKEN_NOT_FOUND');
    if(!pre_)
      _utils.requireValidTime(parent_, id_);
  }


  function beforeMint1155(address parent_, uint id_, uint amount_, bool pre_, PollyAux.Msg memory msg_) public view override {

    _beforeMint(parent_, id_, pre_, msg_);

    _utils.requireValidSupply1155(parent_, id_, amount_);
    _utils.requireValidAmount1155(parent_, id_, amount_);
    if(!pre_)
      _utils.requireValidPrice1155(parent_, id_, amount_, msg_._value);

  }

  function beforeMint721(address parent_, uint id_, bool pre_, PollyAux.Msg memory msg_) public view override {
    _beforeMint(parent_, id_, pre_, msg_);
    if(!pre_)
      _utils.requireValidPrice721(parent_, id_, msg_._value);
  }

  function beforeCreateToken(address, uint id_, PollyToken_v1.MetaEntry[] memory meta_) public pure override returns(uint, PollyToken_v1.MetaEntry[] memory){
    require(meta_.length > 0, 'EMPTY_META');
    return (id_, meta_);
  }


  function tokenURI(address parent_, uint id_) public view override returns (string memory) {

    require(PollyToken_v1(parent_).tokenExists(id_), 'TOKEN_NOT_FOUND');

    Meta_v1 meta_ = PollyToken_v1(parent_).getMetaHandler();

    if(!_stringIsEmpty(meta_.getString(id_, 'metadata_uri')))
      return meta_.getString(id_, 'metadata_uri');

    MusicTokenSchema schema_ = _schema;
    if(meta_.getAddress(id_, 'metadata_schema') != address(0)){
      schema_ = MusicTokenSchema(meta_.getAddress(id_, 'metadata_schema'));
    }
    else
    if(meta_.getAddress(0, 'metadata_schema') != address(0)){
      schema_ = MusicTokenSchema(meta_.getAddress(0, 'metadata_schema'));
    }

    Json_v1.Item[] memory items_ = schema_.populate(id_, PollyToken_v1(parent_), meta_);

    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(bytes(_json.encode(items_, Json_v1.Format.OBJECT)))
      )
    );

  }


}


contract MusicTokenSchema {

  string public constant SCHEMA_ID = 'mnft-20220202';

  function _stringIs(string memory a_, string memory b_) private pure returns (bool) {
    return keccak256(abi.encodePacked(a_)) == keccak256(abi.encodePacked(b_));
  }

  function _stringIsEmpty(string memory string_) private pure returns (bool) {
    return keccak256(abi.encodePacked(string_)) == keccak256(abi.encodePacked(''));
  }

  function get() public pure returns(Json_v1.Item[] memory){

    Json_v1.Item[] memory items_ = new Json_v1.Item[](28);

    // version
    items_[0]._key = 'version';
    items_[0]._type = Json_v1.Type.STRING;
    items_[0]._string = SCHEMA_ID;

    // title
    items_[1]._key = 'title';
    items_[1]._type = Json_v1.Type.STRING;

    // artist
    items_[2]._key = 'artist';
    items_[2]._type = Json_v1.Type.STRING;

    // description
    items_[3]._key = 'description';
    items_[3]._type = Json_v1.Type.STRING;

    // duration
    items_[4]._key = 'duration';
    items_[4]._type = Json_v1.Type.NUMBER;

    // mimeType
    items_[5]._key = 'mimeType';
    items_[5]._type = Json_v1.Type.STRING;

    // trackNumber
    items_[6]._key = 'trackNumber';
    items_[6]._type = Json_v1.Type.NUMBER;

    // project
    items_[7]._key = 'project';
    items_[7]._type = Json_v1.Type.STRING;

    // artwork
    items_[8]._key = 'artwork';
    items_[8]._type = Json_v1.Type.STRING;

    // visualizer
    items_[9]._key = 'visualizer';
    items_[9]._type = Json_v1.Type.STRING;

    // genre
    items_[10]._key = 'genre';
    items_[10]._type = Json_v1.Type.STRING;

    // tags
    items_[11]._key = 'tags';
    items_[11]._type = Json_v1.Type.STRING;

    // lyrics
    items_[12]._key = 'lyrics';
    items_[12]._type = Json_v1.Type.STRING;

    // bpm
    items_[13]._key = 'bpm';
    items_[13]._type = Json_v1.Type.NUMBER;

    // key
    items_[14]._key = 'key';
    items_[14]._type = Json_v1.Type.STRING;

    // license
    items_[15]._key = 'license';
    items_[15]._type = Json_v1.Type.STRING;

    // isrc
    items_[16]._key = 'isrc';
    items_[16]._type = Json_v1.Type.STRING;

    // locationCreated
    items_[17]._key = 'locationCreated';
    items_[17]._type = Json_v1.Type.STRING;

    // originalReleaseDate
    items_[18]._key = 'originalReleaseDate';
    items_[18]._type = Json_v1.Type.STRING;

    // recordLabel
    items_[19]._key = 'recordLabel';
    items_[19]._type = Json_v1.Type.STRING;

    // publisher
    items_[20]._key = 'publisher';
    items_[20]._type = Json_v1.Type.STRING;

    // credits
    items_[21]._key = 'credits';
    items_[21]._type = Json_v1.Type.STRING;

    // losslessAudio
    items_[22]._key = 'losslessAudio';
    items_[22]._type = Json_v1.Type.STRING;

    // image
    items_[23]._key = 'image';
    items_[23]._type = Json_v1.Type.STRING;

    // name
    items_[24]._key = 'name';
    items_[24]._type = Json_v1.Type.STRING;

    // external_url
    items_[25]._key = 'external_url';
    items_[25]._type = Json_v1.Type.STRING;

    // animation_url
    items_[26]._key = 'animation_url';
    items_[26]._type = Json_v1.Type.STRING;

    // attributes
    items_[27]._key = 'attributes';
    items_[27]._type = Json_v1.Type.STRING;

    return items_;

  }

  function populate(uint id_, PollyToken_v1 token_, Meta_v1 meta_) public view returns(Json_v1.Item[] memory){

    Json_v1.Item[] memory items_ = get();

    string memory image_ = token_.image(id_);
    if(_stringIsEmpty(image_))
      image_ = meta_.getString(id_, 'artwork');

    string memory mt_key_;
    for(uint256 i = 0; i < items_.length; i++){

      mt_key_ = string(abi.encodePacked('', items_[i]._key));

      if(_stringIs(items_[i]._key, 'name')){
        items_[i]._string = string(abi.encodePacked(meta_.getString(id_, 'title'), ' - ', meta_.getString(id_, 'artist')));
      }
      else
      if(_stringIs(items_[i]._key, 'artwork') || _stringIs(items_[i]._key, 'image')){
        items_[i]._string = image_;
      }
      else
      if(items_[i]._type == Json_v1.Type.STRING && !_stringIsEmpty(meta_.getString(id_, mt_key_))){
        items_[i]._string = meta_.getString(id_, mt_key_);
      }
      else
      if(items_[i]._type == Json_v1.Type.NUMBER){
        items_[i]._uint = meta_.getUint(id_, mt_key_);
      }

    }

    return items_;
  }


}


contract MusicTokenConfigurator is PollyConfigurator {

  address private _fee_recipient;

  constructor() {
    _fee_recipient = msg.sender;
  }

  function _isValidPollyTokenName(string memory name_) private pure returns(bool) {
    return (
      keccak256(abi.encodePacked(name_)) == keccak256(abi.encodePacked('Token1155'))
      ||
      keccak256(abi.encodePacked(name_)) == keccak256(abi.encodePacked('Token721'))
    );
  }


  function inputs() public pure override returns(string[] memory){

    string[] memory inputs_ = new string[](2);

    inputs_[0] = 'string || Collection name || The name as you want it to appear where this collection is displayed';
    inputs_[1] = 'string || Token type || The token standard to use for this MusicToken || Token1155:ERC1155,Token721:ERC721';

    return inputs_;

  }


  function outputs() public pure override returns(string[] memory){

    string[] memory outputs_ = new string[](2);

    outputs_[0] = 'module || Token module || The token module used for this MusicToken';
    outputs_[1] = 'module || Meta module || The meta module used for this MusicToken';

    return outputs_;

  }

  function fee(Polly polly_, address for_, Polly.Param[] memory params_) public view override returns (uint256) {

    uint fee_ = 0.001 ether;

    if(_isValidPollyTokenName(params_[0]._string)){
      uint mod_fee_ = polly_.getConfiguratorFee(for_, params_[0]._string, 1, new Polly.Param[](0));
      fee_ = mod_fee_+fee_;
    }

    return fee_;
  }

  function run(Polly polly_, address for_, Polly.Param[] memory params_) external virtual override payable returns(Polly.Param[] memory){

      require(params_.length == inputs().length, 'INVALID_PARAMS_COUNT');
      require(_isValidPollyTokenName(params_[1]._string), 'INVALID_TOKEN_NAME');

      Polly.Param[] memory rparams_ = new Polly.Param[](outputs().length);

      MusicToken_v1 mt_ = MusicToken_v1(polly_.getModule('MusicToken', 1).implementation);
      RoyaltyInfo_v1 ri_ = RoyaltyInfo_v1(polly_.getModule('RoyaltyInfo', 1).implementation);

      Polly.Param[] memory token_params_ = new Polly.Param[](4);
      token_params_[0]._address = address(mt_);
      token_params_[1]._address = address(ri_);


      Polly.Param[] memory token_config_ = Polly(polly_).configureModule(
        params_[1]._string,
        1,
        token_params_,
        false,
        ''
      );

      PollyToken_v1 token_ = PollyToken_v1(token_config_[0]._address);
      Meta_v1 meta_ = token_.getMetaHandler();


      // Setup collection name
      meta_.setString(0, 'name', params_[0]._string);

      /// Permissions
      _transfer(token_config_[0]._address, for_); // transfer PollyToken module
      _transfer(token_config_[1]._address, for_); // transfer Meta module

      rparams_[0] = token_config_[0]; // return the token module
      rparams_[1] = token_config_[1]; // return Meta module

      return rparams_;

  }


}
