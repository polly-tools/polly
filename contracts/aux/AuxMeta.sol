//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./../utils/base64.sol";

import "./../Collection.sol";
import "./../Aux.sol";
import "./../Catalogue.sol";
import "./AuxArtwork.sol";

import 'hardhat/console.sol';


////////////////////////////////////
//                                //
//            META v1             //
//                                //
////////////////////////////////////


/// @title Default edition metadata - v1
/// @notice Generates metadata for editions
/// @dev Uses collection and artwork contract to produce metadata including json encoded meta
contract AuxMeta is Aux {

  string[] private _hooks = ['filterGetURI'];

  constructor() {
    registerHooks(_hooks);
  }

  function getAuxInfo() public view returns(IAux.AuxInfo memory){
    return IAux.AuxInfo(
      'meta v1',
      address(this),
      false /// @dev don't clone
    );
  }

  function filterGetURI(
    string memory uri_,
    uint edition_id_
  )
  public view returns(string memory) {

    IAuxHandler aux_handler_ = IAuxHandler(msg.sender);
    ICollection coll_ = ICollection(aux_handler_.getCollectionAddress());
    ICatalogue cat_ = ICatalogue(coll_.getCatalogueAddress());
    ICollection.Edition memory edition_ = coll_.getEdition(edition_id_);

    string memory items_json_ = "";
    for(uint i = 0; i < edition_.items.length; i++) {
      items_json_ = string(abi.encodePacked(items_json_, cat_.getItemJSON(edition_.items[i]), (i < edition_.items.length ? ',' : '')));
      i++;
    }

    string memory artwork_ = aux_handler_.filterGetArtwork('', edition_.id);

    uri_ = string(abi.encodePacked(
      '{',
        '"name": "', edition_.name,'",',
        '"image": "', artwork_,'",',
        '"items": [', items_json_,']'
      '}'
    ));

    return string(abi.encodePacked('data:application/json;base64,', Base64.encode(bytes(uri_))));

  }

}
