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
    "beforeMint1155",
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


  function hooks() public view override returns (string[] memory) {
    return _hooks;
  }


  function beforeMint1155(address parent_, uint id_, uint amount_, PollyAux.Msg memory msg_) public view override {

    require(PollyToken(parent_).tokenExists(id_), 'TOKEN_NOT_FOUND');

  }


  function tokenURI(address parent_, uint id_) public view override returns (string memory) {

    require(PollyToken(parent_).tokenExists(id_), 'TOKEN_NOT_FOUND');

    MetaForIds meta_ = PollyToken(parent_).getMetaHandler();

    Json.Item[] memory items_ = _schema.get();
    string memory image_ = PollyToken(parent_).image(id_);

    // version
    items_[0]._key = 'version';
    items_[0]._type = Json.Type.STRING;
    items_[0]._string = 'mnft-20220202';

    // title
    items_[1]._string = meta_.getString(id_, 'title');

    // artist
    items_[2]._string = meta_.getString(id_, 'artist');

    // description
    items_[3]._string = meta_.getString(id_, 'description');

    // duration
    items_[4]._uint = meta_.getUint(id_, 'duration');

    // mimeType
    items_[5]._string = meta_.getString(id_, 'mimeType');

    // trackNumber
    items_[6]._uint = meta_.getUint(id_, 'trackNumber');

    // project
    items_[7]._string = meta_.getString(id_, 'project');

    // artwork
    items_[8]._string = image_;

    // visualizer
    items_[9]._string = meta_.getString(id_, 'visualizer');

    // genre
    items_[10]._string = meta_.getString(id_, 'genre');

    // tags
    items_[11]._string = meta_.getString(id_, 'tags');

    // lyrics
    items_[12]._string = meta_.getString(id_, 'lyrics');

    // bpm
    items_[13]._uint = meta_.getUint(id_, 'bpm');

    // key
    items_[14]._string = meta_.getString(id_, 'key');

    // license
    items_[15]._string = meta_.getString(id_, 'license');

    // isrc
    items_[16]._string = meta_.getString(id_, 'isrc');

    // locationCreated
    items_[17]._string = meta_.getString(id_, 'locationCreated');

    // originalReleaseDate
    items_[18]._string = meta_.getString(id_, 'originalReleaseDate');

    // recordLabel
    items_[19]._string = meta_.getString(id_, 'recordLabel');

    // publisher
    items_[20]._string = meta_.getString(id_, 'publisher');

    // credits
    items_[21]._string = meta_.getString(id_, 'credits');

    // losslessAudio
    items_[22]._string = meta_.getString(id_, 'losslessAudio');

    // image
    items_[23]._string = image_;

    // name
    items_[24]._string = string(abi.encodePacked(meta_.getString(id_, 'title'), ' - ', meta_.getString(id_, 'artist')));

    // external_url
    items_[25]._string = meta_.getString(id_, 'external_url');

    // animation_url
    items_[26]._string = meta_.getString(id_, 'animation_url');

    // attributes
    items_[27]._string = meta_.getString(id_, 'attributes');

    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(bytes(_json.encode(items_, Json.Format.OBJECT)))
      )
    );

  }


}


contract MusicTokenSchema {

  function get() public pure returns(Json.Item[] memory){

    Json.Item[] memory items_ = new Json.Item[](28);

    // version
    items_[0]._key = 'version';
    items_[0]._type = Json.Type.STRING;

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

      uint polly_token_fee_ = polly_.getConfiguratorFee(msg.sender, params_[0]._string, 1, new Polly.Param[](0));
      Polly.Param[] memory config_ = Polly(polly_).configureModule{value: polly_token_fee_}(
        params_[0]._string,
        1,
        new Polly.Param[](0),
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
