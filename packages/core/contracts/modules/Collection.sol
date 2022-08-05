//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../PollyModule.sol";
import "../PollyAux.sol";
import "./Catalogue.sol";


////////////////////////////////////////////////////
///
/// COLLECTION
///
/// A Polly module for creating digital editions of
/// stuff. Supports auxiliary contracts for added
/// functionality.
///
////////////////////////////////////////////////////



/// INTERFACES
interface ICollection is IPollyModule, IERC1155 {

    struct Edition {
        uint id;
        string name;
        string creator;
        uint price;
        uint supply;
        address recipient;
        uint[] items;
        bool released;
        bool finalized;
    }

    struct EditionInput {
        string name;
        string creator;
        uint price;
        uint supply;
        address recipient;
        ICatalogue.Item[] items;
    }

    function totalSupply(uint edition_id_) external view returns(uint);

    function createEdition(ICollection.EditionInput memory edition_input_) external returns(uint);
    function getEdition(uint edition_id_, bool filtered_) external view returns(Edition memory);
    function addItem(uint edition_id_) external;
    function removeItem(uint edition_id_, uint index_) external;

    function addAux(address aux_) external;

}


/// CONTRAT

contract Collection is ERC1155, ERC1155Supply, ReentrancyGuard, PollyModule {

    uint private _edition_ids;
    mapping(uint => ICollection.Edition) private _editions;

    constructor() ERC1155("") PollyModule(){
      _setConfigurator(address(new CollectionConfigurator()));
    }


    /**
    ***********************************
    || EVENTS
    ***********************************
    */

    event EditionCreated(uint edition_id_);


    function getInfo() public pure returns(IPollyModule.Info memory){
        return IPollyModule.Info('collection', true);
    }

    function hasAuxHandler() public view returns(bool has_){
        if(getAddress('aux_handler') != address(0))
            has_ = true;
        return has_;
    }




    /**
    ***********************************
    || PUBLIC FUNCTIONS
    ***********************************
    */

    /// @dev create a new edition
    /// @param edition_input_ a struct containing all edition info
    function createEdition(ICollection.EditionInput memory edition_input_) public onlyRole(MANAGER) returns(uint) {

        /** Create an array with the length of number of items */
        uint[] memory items_ = new uint[](edition_input_.items.length);

        uint item_id_; // Placeholder var for iterating over the items:
        ICatalogue cat_ = ICatalogue(getAddress('catalogue')); // Fetch the catalogue address and instantiate it

        uint i = 0; // Iterator var

        /**
        Iterate all the input items and create them in the catalogue
        */
        while(i < edition_input_.items.length) {
            item_id_ = cat_.createItem(edition_input_.items[i]);
            items_[i] = item_id_;
            ++i;
        }

        _edition_ids++; // Increment the current edition ID

        /**
        Create the new edition and add it to the collection
        */
        ICollection.Edition memory edition_ = ICollection.Edition(
            _edition_ids, // edition ID
            edition_input_.name, // edition name
            edition_input_.creator, // edition creator
            edition_input_.price, // editions price
            edition_input_.supply, // edition supply
            edition_input_.recipient, // edition recipient
            items_, // The array of item IDs from the catalogue
            true, // Set to released immediatly. QUESTION: should this be togglable or is it okay to filter only?
            true // Set to finalized immediatly. QUESTION: should this be togglable or is it okay to filter only?
        );

        _editions[_edition_ids] = edition_; // Add to collection

        /**
        Emit event and return current edition id
        */
        emit EditionCreated(_edition_ids);
        return _edition_ids;

    }



    /**
    @dev retrieves and edition by the edition_id_
    @param edition_id_ id of edition to fetch
    @param filtered_ pass true to fetch the filtered edition
    */
    function getEdition(uint edition_id_, bool filtered_) public view returns(ICollection.Edition memory edition_) {

        edition_ = _editions[edition_id_]; // Get edition;

        /**
        Filter result if there's a aux handler and the filtered_ var is true
        */
        if(filtered_ && hasAuxHandler())
            edition_ = ICollectionAuxHandler(getAddress('aux_handler')).filterGetEdition(edition_);

        return edition_;

    }


    function getEditionCount() public view returns(uint){
        return _edition_ids;
    }


	/**
    @dev mint an edition to tx sender
    */
    function mint(uint edition_id_) public payable nonReentrant {

		/** First get the edition by edition_id_ */
        ICollection.Edition memory edition_ = getEdition(edition_id_, true);

        require(edition_.released, "UNRELEASED"); // Edition must be released
        require(msg.value >= edition_.price, "INVALID_PRICE"); // Edition price must be met
        require(edition_.supply > 0, "NOT_AVAILABLE"); // Edition supply must be more than 0

        ICollectionAuxHandler aux_ = ICollectionAuxHandler(getAddress('aux_handler')); // Init aux_ var

        /** If there's a AUX handler connected run actionBeforeMint */
		if(hasAuxHandler())
        	aux_.actionBeforeMint(edition_id_, msg.sender);

        /**
        If the edition has a price and a recipient attempt to transfer the funds
        */
        if(edition_.price > 0 && edition_.recipient != address(0)){
            (bool sent,) =  _editions[edition_id_].recipient.call{value: msg.value}("");
            require(sent, "EDITION_TRANSFER_FAILED");
        }

        /** Mint 1 of each edition for minter */
        _mint(msg.sender, edition_id_, 1, "");

        /** If there's a AUX handler connected run actionAfterMint */
		if(hasAuxHandler())
	        aux_.actionAfterMint(edition_id_, msg.sender);

    }

	/**
    @dev returns the token URI for a given edition
    */
    function uri(uint edition_id_) public view override returns(string memory uri_){

		uri_ = getString('uri'); // Get the uri string

		/** Filter the URI if there's a aux handler connected */
		if(hasAuxHandler())
			uri_ = ICollectionAuxHandler(getAddress('aux_handler')).filterGetURI(uri_, edition_id_);

    	return uri_;

    }



    /**
    ***********************************
    || OVERRIDES
    ***********************************
    */

    function _beforeTokenTransfer( address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual override (ERC1155, ERC1155Supply){
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool){
        return super.supportsInterface(interfaceId);
    }

}







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
        return IPollyModule.Info('collection.aux_handler', true);
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









contract CollectionConfigurator is PollyConfigurator {


    struct Config {
        address collection;
        address catalogue;
        address aux_handler;
    }

    // function getInfo() public pure returns(IPollyModule.Info memory){
    //     return IPollyModule.Info('collection.configurator', false);
    // }



    function run(Polly polly_, address for_, PollyConfigurator.InputParam[] memory params_) public override returns(PollyConfigurator.ReturnParam[] memory){

        Config memory config_;

        // CLONE
        config_.catalogue = polly_.cloneModule('catalogue', 0);
        config_.collection = polly_.cloneModule('collection', 0);
        if(params_[0]._bool)
            config_.aux_handler = polly_.cloneModule('collection.aux_handler', 0); // Use a aux_handler?


        Collection coll_ = Collection(config_.collection);
        Catalogue cat_ = Catalogue(config_.catalogue);

        // SET PERMISSIONS FOR CALLER
        cat_.grantRole(DEFAULT_ADMIN_ROLE, for_);
        coll_.grantRole(DEFAULT_ADMIN_ROLE, for_);
        cat_.grantRole(MANAGER, for_);
        coll_.grantRole(MANAGER, for_);

        // SET PERMISSIONS
        cat_.grantRole(MANAGER, address(coll_));
        coll_.setAddress('catalogue', config_.catalogue);
        coll_.setAddress('catalogue', config_.catalogue);

        PollyConfigurator.ReturnParam[] memory rparams_ = new PollyConfigurator.ReturnParam[](3);

        rparams_[0] = PollyConfigurator.ReturnParam('catalogue', '', 0, false, config_.catalogue);
        rparams_[1] = PollyConfigurator.ReturnParam('collection', '', 0, false, config_.collection);

        if(config_.aux_handler != address(0)){

            rparams_[2] = PollyConfigurator.ReturnParam('aux_handler', '', 0, false, config_.aux_handler);

            CollectionAuxHandler aux_handler_ = CollectionAuxHandler(config_.aux_handler);

            aux_handler_.grantRole(DEFAULT_ADMIN_ROLE, for_);

            cat_.grantRole(MANAGER, config_.aux_handler);
            coll_.grantRole(MANAGER, config_.aux_handler);


            coll_.setAddress('aux_handler', config_.aux_handler);
            aux_handler_.grantRole(MANAGER, config_.collection);

        }

        // REMOVE PERMISSIONS FOR THIS
        cat_.revokeRole(MANAGER, address(this));
        coll_.revokeRole(MANAGER, address(this));
        cat_.revokeRole(DEFAULT_ADMIN_ROLE, address(this));
        coll_.revokeRole(DEFAULT_ADMIN_ROLE, address(this));


        return rparams_;

    }

}
