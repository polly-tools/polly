//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@polly-os/core/contracts/PollyModule.sol";
import "@polly-os/core/contracts/PollyAux.sol";
import "./Collection.sol";


////////////////////////
///                  ///
///  COLLECTION AUX  ///
///                  ///
////////////////////////


interface ICollectionHooks {

  function actionBeforeCreateEdition(ICollection.Edition memory edition_, address sender_) external;
  function actionAfterCreateEdition(ICollection.Edition memory edition_, address sender_) external;
  function actionBeforeMint(uint edition_id_, address sender_) external;
  function actionAfterMint(uint edition_id_, address sender_) external;

  function filterGetEdition(ICollection.Edition memory edition_) external view returns(ICollection.Edition memory);
  function filterGetURI(string memory uri_, uint edition_id_) external view returns(string memory);
  function filterGetArtwork(string memory artwork_, uint edition_id_) external view returns(string memory);

}

interface ICollectionAux is ICollectionHooks, IPollyAux {}
interface ICollectionAuxHandler is ICollectionHooks, IPollyAuxHandler {}


contract CollectionAuxHandler is PollyModule, PollyAuxHandler {


    function getInfo() public pure returns(IPollyModule.Info memory){
        return IPollyModule.Info('polly.CollectionAuxHandler', true);
    }

    function configure(address catalogue_, address collection_, address aux_handler_) public onlyRole(DEFAULT_ADMIN_ROLE) {
                
        (bool s1,) = catalogue_.delegatecall(abi.encodeWithSignature('grantRole(bytes32,address)', MANAGER, address(this)));
        (bool s2,) = collection_.delegatecall(abi.encodeWithSignature('grantRole(bytes32,address)', MANAGER, address(this)));

        if(aux_handler_ != address(0)){
            (bool s3,) = collection_.delegatecall(abi.encodeWithSignature('setAddress(string,address)', 'aux_handler', aux_handler_));
            grantRole(MANAGER, collection_);
        }

    }

    // ACTIONS
    function actionBeforeMint(uint edition_id_, address sender_) public onlyRole(MANAGER) {
        address[] memory hooks_ = getAuxForHook('actionBeforeMint');
        for(uint i = 0; i < hooks_.length; i++) {
            ICollectionAux(hooks_[i]).actionBeforeMint(edition_id_, sender_);
        }
    }


    function actionAfterMint(uint edition_id_, address sender_) public onlyRole(MANAGER) {
        address[] memory hooks_ = getAuxForHook('actionAfterMint');
        for(uint i = 0; i < hooks_.length; i++) {
            ICollectionAux(hooks_[i]).actionAfterMint(edition_id_, sender_);
        }
    }

    function actionBeforeCreateEdition(ICollection.Edition memory edition_, address sender_) public onlyRole(MANAGER) {
        address[] memory hooks_ = getAuxForHook('actionBeforeCreateEdition');
        for(uint i = 0; i < hooks_.length; i++) {
            ICollectionAux(hooks_[i]).actionBeforeCreateEdition(edition_, sender_);
        }
    }

    function actionAfterCreateEdition(ICollection.Edition memory edition_, address sender_) public onlyRole(MANAGER) {
        address[] memory hooks_ = getAuxForHook('actionAfterCreateEdition');
        for(uint i = 0; i < hooks_.length; i++) {
            ICollectionAux(hooks_[i]).actionAfterCreateEdition(edition_, sender_);
        }
    }


    // FILTERS

    function filterGetEdition(ICollection.Edition memory edition_) public view returns(ICollection.Edition memory) {
        address[] memory hooks_ = getAuxForHook('filterGetEdition');
        for(uint256 i = 0; i < hooks_.length; i++) {
            edition_ = ICollectionAux(hooks_[i]).filterGetEdition(edition_);
        }
        return edition_;
    }

    function filterGetURI(string memory uri_, uint edition_id_) external view onlyRole(MANAGER) returns(string memory){
        address[] memory hooks_ = getAuxForHook('filterGetURI');
        for(uint256 i = 0; i < hooks_.length; i++) {
            uri_ = ICollectionAux(hooks_[i]).filterGetURI(uri_, edition_id_);
        }

        return uri_;
    }

    function filterGetArtwork(string memory artwork_, uint edition_id_) external view onlyRole(MANAGER) returns(string memory){
        address[] memory hooks_ = getAuxForHook('filterGetArtwork');
        for(uint256 i = 0; i < hooks_.length; i++) {
            artwork_ = ICollectionAux(hooks_[i]).filterGetArtwork(artwork_, edition_id_);
        }

        return artwork_;
    }


}


abstract contract CollectionAux is PollyAux {


}
