//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@polly-os/core/contracts/PollyModule.sol";
import "@polly-os/core/contracts/PollyAux.sol";

import "./CollectionAux.sol";
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

    constructor() ERC1155("") PollyModule(){}


    function configure(address collection_, address catalogue_) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {        
        (bool s1,) = collection_.delegatecall(abi.encodeWithSignature('setAddress(string,address)', 'catalogue', catalogue_));
        (bool s2,) = catalogue_.delegatecall(abi.encodeWithSignature('grantRole(bytes32,address)', PollyModule(catalogue_).MANAGER(), collection_));
        if(s1 && s2)
            return true;
        return false;
    }

    /**
    ***********************************
    || EVENTS
    ***********************************
    */

    event EditionCreated(uint edition_id_);


    function getInfo() public pure returns(IPollyModule.Info memory){
        return IPollyModule.Info('polly.Collection', true);
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
