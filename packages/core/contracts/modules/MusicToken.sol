//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import '../Polly.sol';
import '../PollyConfigurator.sol';
import './shared/PollyToken.sol';
import 'base64-sol/base64.sol';


contract MusicToken is PMReadOnly, PollyTokenAux {

  struct MetaItem {
    string _key;
    Json.Type _type;
  }

  string public constant override PMNAME = "MusicToken";
  uint256 public constant override PMVERSION = 1;
  string public constant override PMINFO = "MusicToken | format token metadata for music";

  MusicTokenSchema private _schema;
  Json private _json;

  string[] private _hooks = [
    "beforeCreateToken",
    "beforeMint1155",
    "beforeMint721",
    "tokenURI"
  ];

  constructor(address polly_){

    _json = Json(
      Polly(polly_)
      .getModule('Json', 1)
      .implementation
    );

    _schema = new MusicTokenSchema();

    _setConfigurator(address(new MusicTokenConfigurator()));

  }


  function _stringIsEmpty(string memory string_) private pure returns (bool) {
    return keccak256(abi.encodePacked(string_)) == keccak256(abi.encodePacked(''));
  }


  function hooks() public view override returns (string[] memory) {
    return _hooks;
  }


  /// @dev internal function to run on beforeMint1155 and beforeMint721
  function _beforeMint(address parent_, uint id_, PollyAux.Msg memory msg_) private view returns(MetaForIds) {
    require(PollyToken(parent_).tokenExists(id_), 'TOKEN_NOT_FOUND');
    MetaForIds meta_ = PollyToken(parent_).getMetaHandler();
    require(msg_._value >= meta_.getUint(id_, 'mt.min_price'), 'INVALID_PRICE');
    return meta_;
  }


  function beforeMint1155(address parent_, uint id_, uint amount_, PollyAux.Msg memory msg_) public view override {
    MetaForIds meta_ = _beforeMint(parent_, id_, msg_);
    if(meta_.getUint(id_, 'mt.max_mint') > 0)
      require(amount_ <= meta_.getUint(id_, 'mt.max_mint'), 'MAX_MINT_EXCEEDED');

  }

  function beforeMint721(address parent_, uint id_, PollyAux.Msg memory msg_) public view override {
    _beforeMint(parent_, id_, msg_);
  }

  function beforeCreateToken(address, uint id_, PollyToken.Meta[] memory meta_) public pure override returns(uint, PollyToken.Meta[] memory){
    require(meta_.length > 0, 'EMPTY_META');
    for(uint i = 0; i < meta_.length; i++){
      meta_[i]._key = string(abi.encodePacked('mt.', meta_[i]._key));
    }
    return (id_, meta_);
  }


  function tokenURI(address parent_, uint id_) public view override returns (string memory) {

    require(PollyToken(parent_).tokenExists(id_), 'TOKEN_NOT_FOUND');

    MetaForIds meta_ = PollyToken(parent_).getMetaHandler();

    if(!_stringIsEmpty(meta_.getString(id_, 'mt.metadata_uri')))
      return meta_.getString(id_, 'mt.metadata_uri');

    MusicTokenSchema schema_ = _schema;
    if(meta_.getAddress(id_, 'mt.schema') != address(0)){
      schema_ = MusicTokenSchema(meta_.getAddress(id_, 'mt.schema'));
    }
    else
    if(meta_.getAddress(0, 'mt.schema') != address(0)){
      schema_ = MusicTokenSchema(meta_.getAddress(0, 'mt.schema'));
    }

    Json.Item[] memory items_ = schema_.populate(id_, PollyToken(parent_), meta_);

    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(bytes(_json.encode(items_, Json.Format.OBJECT)))
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

  function get() public pure returns(Json.Item[] memory){

    Json.Item[] memory items_ = new Json.Item[](28);

    // version
    items_[0]._key = 'version';
    items_[0]._type = Json.Type.STRING;
    items_[0]._string = 'mnft-20220202';

    // title
    items_[1]._key = 'title';
    items_[1]._type = Json.Type.STRING;

    // artist
    items_[2]._key = 'artist';
    items_[2]._type = Json.Type.STRING;

    // description
    items_[3]._key = 'description';
    items_[3]._type = Json.Type.STRING;

    // duration
    items_[4]._key = 'duration';
    items_[4]._type = Json.Type.NUMBER;

    // mimeType
    items_[5]._key = 'mimeType';
    items_[5]._type = Json.Type.STRING;

    // trackNumber
    items_[6]._key = 'trackNumber';
    items_[6]._type = Json.Type.NUMBER;

    // project
    items_[7]._key = 'project';
    items_[7]._type = Json.Type.STRING;

    // artwork
    items_[8]._key = 'artwork';
    items_[8]._type = Json.Type.STRING;

    // visualizer
    items_[9]._key = 'visualizer';
    items_[9]._type = Json.Type.STRING;

    // genre
    items_[10]._key = 'genre';
    items_[10]._type = Json.Type.STRING;

    // tags
    items_[11]._key = 'tags';
    items_[11]._type = Json.Type.STRING;

    // lyrics
    items_[12]._key = 'lyrics';
    items_[12]._type = Json.Type.STRING;

    // bpm
    items_[13]._key = 'bpm';
    items_[13]._type = Json.Type.NUMBER;

    // key
    items_[14]._key = 'key';
    items_[14]._type = Json.Type.STRING;

    // license
    items_[15]._key = 'license';
    items_[15]._type = Json.Type.STRING;

    // isrc
    items_[16]._key = 'isrc';
    items_[16]._type = Json.Type.STRING;

    // locationCreated
    items_[17]._key = 'locationCreated';
    items_[17]._type = Json.Type.STRING;

    // originalReleaseDate
    items_[18]._key = 'originalReleaseDate';
    items_[18]._type = Json.Type.STRING;

    // recordLabel
    items_[19]._key = 'recordLabel';
    items_[19]._type = Json.Type.STRING;

    // publisher
    items_[20]._key = 'publisher';
    items_[20]._type = Json.Type.STRING;

    // credits
    items_[21]._key = 'credits';
    items_[21]._type = Json.Type.STRING;

    // losslessAudio
    items_[22]._key = 'losslessAudio';
    items_[22]._type = Json.Type.STRING;

    // image
    items_[23]._key = 'image';
    items_[23]._type = Json.Type.STRING;

    // name
    items_[24]._key = 'name';
    items_[24]._type = Json.Type.STRING;

    // external_url
    items_[25]._key = 'external_url';
    items_[25]._type = Json.Type.STRING;

    // animation_url
    items_[26]._key = 'animation_url';
    items_[26]._type = Json.Type.STRING;

    // attributes
    items_[27]._key = 'attributes';
    items_[27]._type = Json.Type.STRING;

    return items_;

  }

  function populate(uint id_, PollyToken token_, MetaForIds meta_) public view returns(Json.Item[] memory){

    Json.Item[] memory items_ = get();

    string memory image_ = token_.image(id_);
    if(_stringIsEmpty(image_))
      image_ = meta_.getString(id_, 'mt.artwork');

    string memory mt_key_;
    for(uint256 i = 0; i < items_.length; i++){

      mt_key_ = string(abi.encodePacked('mt.', items_[i]._key));

      if(_stringIs(items_[i]._key, 'name')){
        items_[i]._string = string(abi.encodePacked(meta_.getString(id_, 'mt.title'), ' - ', meta_.getString(id_, 'mt.artist')));
      }
      else
      if(_stringIs(items_[i]._key, 'artwork') || _stringIs(items_[i]._key, 'image')){
        items_[i]._string = image_;
      }
      else
      if(items_[i]._type == Json.Type.STRING && !_stringIsEmpty(meta_.getString(id_, mt_key_))){
        items_[i]._string = meta_.getString(id_, mt_key_);
      }
      else
      if(items_[i]._type == Json.Type.NUMBER){
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
      keccak256(abi.encodePacked(name_)) == keccak256(abi.encodePacked('Polly1155'))
      ||
      keccak256(abi.encodePacked(name_)) == keccak256(abi.encodePacked('Polly721'))
    );
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

      require(_isValidPollyTokenName(params_[0]._string), 'INVALID_TOKEN_NAME');

      Polly.Param[] memory rparams_ = new Polly.Param[](3);

      MusicToken mt_ = MusicToken(polly_.getModule('MusicToken', 1).implementation);
      rparams_[0]._address = address(mt_); // Return MusicToken address

      Polly.Param[] memory token_params_ = new Polly.Param[](1);
      token_params_[0]._address = address(mt_);
      Polly.Param[] memory config_ = Polly(polly_).configureModule(
        params_[0]._string,
        1,
        token_params_,
        false,
        ''
      );

      rparams_[1]._address = config_[0]._address; // return PollyToken module
      rparams_[2]._address = config_[1]._address; // return MetaForIds module


      /// Permissions
      _transfer(rparams_[1]._address, for_); // transfer PollyToken module
      _transfer(rparams_[2]._address, for_); // transfer MetaForIds module

      return rparams_;

  }


}
