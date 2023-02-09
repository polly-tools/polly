// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@polly-tools/module-json/contracts/Json.sol";
import "@polly-tools/module-meta/contracts/Meta.sol";
import "@polly-tools/module-token-utils/contracts/TokenUtils.sol";
import "@polly-tools/polly-token/contracts/PollyToken.sol";
import "@polly-tools/module-token-registry/contracts/TokenRegistry.sol";
import "@polly-tools/core/contracts/Polly.sol";

import "base64-sol/base64.sol";


contract Collection is PMReadOnly {

    // Polly
    string public constant override PMNAME = "Collection";
    uint256 public constant override PMVERSION = 1;

    // Polly private _polly;
    // Json private _json;


    // constructor
    constructor() {
        _setConfigurator(address(new CollectionConfigurator()));
        // _polly = Polly(polly_);
        // _json = Json(_polly.getModule("Json", 1).implementation);
    }


    // Utils
    // function stringIsEmpty(string memory string_) public pure returns (bool) {
    //     return keccak256(abi.encodePacked(string_)) == keccak256(abi.encodePacked(''));
    // }


    // function stringEquals(string memory a_, string memory b_) public pure returns (bool) {
    //     return keccak256(abi.encodePacked(a_)) == keccak256(abi.encodePacked(b_));
    // }





    // function hooks() public view virtual override returns (string[] memory) {
    //     string[] memory hooks_ = new string[](2);
    //     hooks_[0] = "action:afterCreateToken";
    //     hooks_[1] = "filter:uri";
    //     return hooks_;
    // }


    // function filter(string memory hook_, uint id_, Polly.Param memory param_, Msg memory) public view override returns (Polly.Param memory) {

    //     PollyToken token_ = PollyToken(msg.sender);

    //     if(_stringEquals(hook_, "filter:uri")) {
    //         param_._string = getJson(token_, id_);
    //     }

    //     return param_;

    // }


    // function getJson(PollyToken token_, uint id_) public view returns (string memory) {

    //     string memory string_;
    //     Json.Item[] memory items_ = new Json.Item[](10);

    //     items_[0]._key = "name";
    //     items_[0]._type = Json.Type.STRING;
    //     items_[1]._string = token_.getMeta(id_, "name")._string;

    //     items_[1]._key = "description";
    //     items_[1]._type = Json.Type.STRING;
    //     items_[1]._string = token_.getMeta(id_, "description")._string;

    //     items_[2]._key = "image";
    //     items_[2]._type = Json.Type.STRING;
    //     items_[2]._string = token_.getMeta(id_, "image")._string;

    //     items_[3]._key = "media";
    //     items_[3]._type = Json.Type.STRING;
    //     items_[3]._string = token_.getMeta(id_, "media")._string;

    //     items_[4]._key = "app";
    //     items_[4]._type = Json.Type.STRING;
    //     items_[4]._string = token_.getMeta(id_, "app")._string;

    //     items_[5]._key = "data";
    //     items_[5]._type = Json.Type.STRING;
    //     items_[5]._string = token_.getMeta(id_, "data")._string;

    //     items_[6]._key = "license";
    //     items_[6]._type = Json.Type.STRING;
    //     string memory license_ = token_.getMeta(id_, "license")._string;
    //     items_[6]._string = _stringIsEmpty(license_) ? "All rights reserved" : license_;


    //     // Legacy
    //     items_[7]._key = "animation_url";
    //     items_[7]._type = Json.Type.STRING;
    //     items_[7]._string = token_.getMeta(id_, "media")._string;

    //     items_[8]._key = "external_url";
    //     items_[8]._type = Json.Type.STRING;

    //     if(_stringIsEmpty(token_.getMeta(0, "external_url_base")._string)) {
    //         items_[8]._string = token_.getMeta(id_, "external_url")._string;
    //     } else {
    //         items_[8]._string = string(abi.encodePacked(
    //             token_.getMeta(0, "external_url_base")._string,
    //             token_.getMeta(id_, "external_url")._string
    //         ));
    //     }


    //     items_[9]._key = "attributes";
    //     items_[9]._type = Json.Type.ARRAY;

    //     /* Create attributes array */
    //     Json.Item[] memory attribute_ = new Json.Item[](2);

    //     attribute_[0]._key = "trait_type";
    //     attribute_[1]._key = "value";

    //     Json.Item[] memory attributes_ = new Json.Item[](1);

    //     attribute_[0]._type = Json.Type.STRING;
    //     attribute_[1]._type = Json.Type.STRING;
    //     attribute_[0]._string = "Artist";
    //     attribute_[1]._string = token_.getMeta(id_, "artist")._string;

    //     attributes_[0]._type = Json.Type.OBJECT;
    //     attributes_[0]._string = _json.encode(attribute_, Json.Format.OBJECT);

    //     items_[9]._string = _json.encode(attributes_, Json.Format.ARRAY);


    //     // Encode JSON and create data uri
    //     string_ = string(abi.encodePacked(
    //         'data:application/json;base64,',
    //         Base64.encode(bytes(_json.encode(items_, Json.Format.OBJECT)))
    //     ));


    //     return string_;

    // }




}




/////////////////////////
// CONFIGURATION
/////////////////////////


contract CollectionConfigurator is PollyConfigurator {


    function _isValidPollyTokenName(string memory name_) private pure returns(bool) {
        return (
        keccak256(abi.encodePacked(name_)) == keccak256(abi.encodePacked('Token1155'))
        ||
        keccak256(abi.encodePacked(name_)) == keccak256(abi.encodePacked('Token721'))
        );
    }


    function inputs() public pure override returns(string[] memory){

        string[] memory inputs_ = new string[](3);

        inputs_[0] = 'string || Name || The name as you want it to appear where this collection is displayed';
        inputs_[1] = 'string || Token type || The token standard to use for this collection || [Token1155:ERC1155,Token721:ERC721]';
        inputs_[2] = 'address,uint || Royalty.Recipient,Royalty.Base || The address and base of the royalty recipient || 0x0000000000000000000000000000000000000000,0';

        return inputs_;

    }


    function outputs() public pure override returns(string[] memory){

        string[] memory outputs_ = new string[](2);

        outputs_[0] = 'module || Token module || The token module used for this collection';
        outputs_[1] = 'module || Meta module || The meta module used for this collection';

        return outputs_;

    }


    function run(Polly polly_, address for_, Polly.Param[] memory params_) external virtual override payable returns(Polly.Param[] memory){

        require(_isValidPollyTokenName(params_[1]._string), 'INVALID_TOKEN_NAME');

        Polly.Param[] memory rparams_ = new Polly.Param[](outputs().length);

        TokenUtils utils_ = TokenUtils(polly_.getModule('TokenUtils', 1).implementation);

        uint input_count = inputs().length;

        Polly.Param[] memory token_params_ = new Polly.Param[](1+params_.length-input_count);
        token_params_[0]._address = address(utils_);

        // Any additional params are passed to the token module and will be installed as plugins
        for(uint i = input_count; i < params_.length; i++) {
            token_params_[i-input_count+1] = params_[i];
        }


        Polly.Param[] memory token_config_ = Polly(polly_).configureModule(
            params_[1]._string,
            1,
            token_params_,
            false,
            ''
        );

        PollyToken token_ = PollyToken(token_config_[0]._address);
        Meta meta_ = token_.getMetaHandler();


        // Setup collection name
        meta_.setString(0, 'contract.name', params_[0]._string);
        meta_.setUint(0, 'royalty.base', params_[2]._uint);
        meta_.setAddress(0, 'royalty.recipient', params_[2]._address);

        /// Permissions
        _transfer(token_config_[0]._address, for_); // transfer PollyToken module
        _transfer(token_config_[1]._address, for_); // transfer Meta module

        rparams_[0] = token_config_[0]; // return the token module
        rparams_[1] = token_config_[1]; // return Meta module

        return rparams_;

    }

}
