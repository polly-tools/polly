// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./PollyToken.sol";

contract PollyTokenEnum {

    constructor(){}

    struct Token {
        uint id;
        PollyToken.MetaEntry[] meta;
    }

    function list(address address_, uint limit_, uint page_) public view returns (uint[] memory) {

        uint[] memory ids = new uint[](limit_);

        uint offset_ = 1;
        if(page_ > 1){
            offset_ = ((page_ -1) * limit_) +1;
        }

        PollyToken token_ = PollyToken(address_);
        uint i = 0;

        for(uint j = offset_; j < offset_ + limit_; j++){
            if(token_.tokenExists(j)){
                ids[i] = j;
                i++;
            }
        }

        return ids;

    }


    function list(address address_, uint limit_, uint page_, string[] memory keys_) public view returns (Token[] memory) {

        Token[] memory tokens = new Token[](limit_);

        uint offset_ = 1;
        if(page_ > 1){
            offset_ = ((page_ -1) * limit_) +1;
        }

        PollyToken token_ = PollyToken(address_);
        uint i = 0;

        for(uint j = offset_; j < offset_ + limit_; j++){
            if(token_.tokenExists(j)){
                tokens[i].id = j;
                tokens[i].meta = new PollyToken.MetaEntry[](keys_.length);
                for(uint k = 0; k < keys_.length; k++){
                    tokens[i].meta[k] = PollyToken.MetaEntry(keys_[k], token_.getMeta(j, keys_[k]));
                }
                i++;
            }
        }

        return tokens;

    }

}
