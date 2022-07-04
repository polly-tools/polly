//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@polly-os/core/contracts/Polly.sol";
import "./CatalogueAux.sol";

////////////////////////////////////////////////////
///
/// CATALOGUE
///
/// A Polly module for managing metadata for any
/// type of item. Supports per-item permissions,
/// multiple media sources and auxiliary contracts.
/// 
////////////////////////////////////////////////////


interface ICatalogue is IPollyModule {

    struct Item {
        string name;
        string creator;
        string checksum;
        string[] sources;
    }

    struct Meta {
        string key;
        string value;
    }

    // Items
    function getItem(uint item_id_) external view returns(Item memory);
    function getItems(uint[] memory item_ids_) external view returns(Item[] memory);
    function createItem(Item memory item_) external returns(uint);
    function getItemJSON(uint item_id_) external view returns(string memory);
    function updateItem(uint item_id_, string memory name_, string memory creator_, string memory checksum_) external;
    function updateItemName(uint item_id_, string memory name_) external;
    function updateItemCreator(uint item_id_, string memory creator_) external;
    function updateItemChecksum(uint item_id_, string memory checksum_) external;

    // Sources
    function addSource(uint item_id_, string memory source) external;
    function addSources(uint item_id_, string[] memory source) external;

}


contract Catalogue is PollyModule {

    using Counters for Counters.Counter;

    /// @dev item ids
    uint private _item_ids;

    /// @dev Item mappings
    mapping(uint => ICatalogue.Item) private _items; /// @dev item_id => ICatalogue.item struct
    mapping(uint => mapping(string => string)) private _meta; /// @dev item_id => (key => value)

    /// @dev Maps like item_id => role => address => granted;
    mapping(uint => mapping(string => mapping(address => bool))) private _item_roles; /// @dev item_id => (role => (address => granted))

    // EVENTS
    event itemCreated(uint indexed id, address indexed by);
    event itemUpdated(uint indexed id);
    event sourceAdded(uint indexed id, string source);
    event metaUpdated(uint indexed id, string indexed key, string indexed value);
    event metaDeleted(uint indexed id, string indexed key, string indexed value);

    function getModuleInfo() public view returns(IPollyModule.ModuleInfo memory){
        return IPollyModule.ModuleInfo('polly.Catalogue', address(this), true);
    }

    function hasAuxHandler() public view returns(bool has_){
        return (getAddress('aux_handler') != address(0));
    }



    /**
    ***********************************
    || ITEMS
    ***********************************
    */

    /**
    @dev internal function to create new item for a given address
    */
    function _createItemFor(ICatalogue.Item memory item_, address for_) private returns(uint item_id_){

        _item_ids++;
        item_id_ = _item_ids;

        _items[item_id_] = item_;

        _grantAllItemRoles(for_, item_id_);

        emit itemCreated(item_id_, for_);
        return item_id_;

    }


    /**
    @dev Creates a item entry in _items from the ICatalogue.Item Item struct passed in
    via item_. Sets the current sender as admin of the item.
    */
    function createItem(ICatalogue.Item memory item_) public onlyRole(MANAGER) returns(uint){
        return _createItemFor(item_, msg.sender);
    }

    /// @dev check if an item exists
    function itemExists(uint item_id_) public view returns(bool){
        return (item_id_ > 0 && item_id_ <= _item_ids);
    }

    /// @dev retrieves a given item based on item_id_
    function getItem(uint item_id_) public view returns (ICatalogue.Item memory) {
        require(itemExists(item_id_), "INVALID_ITEM");
        return _items[item_id_];
    }

    /// @dev retrieves a set of items based on item_ids_ array of uints
    function getItems(uint[] memory item_ids_) public view returns (ICatalogue.Item[] memory) {

        ICatalogue.Item[] memory items_;
        for (uint i = 0; i < item_ids_.length; i++) {
            items_[i] = getItem(item_ids_[i]);
        }
        return items_;

    }


    /// @dev helper function that produces a JSON object for a given item
    function getItemJSON(uint item_id_) public view returns(string memory){

        ICatalogue.Item memory item_ = getItem(item_id_);
        string memory source_string_;
        uint source_count_ = item_.sources.length;
        uint i = 1;
        while(i <= source_count_) {
            source_string_ = string(abi.encodePacked(source_string_, '"', item_.sources[i],'"', (i < source_count_ ? ',' : '')));
            i++;
        }

        return string(abi.encodePacked('{', '"name":"', item_.name, '", "creator": "',item_.creator,'", "checksum": "',item_.checksum,'", "sources": [',source_string_,']}'));

    }




    /**
    ***********************************
    || ITEM ROLES
    ***********************************
    */

    modifier onlyItemRole(uint item_id_, string memory role_){
        require(itemExists(item_id_), "INVALID_ITEM");
        require(hasItemAccess(msg.sender, item_id_, role_), "MISSING_ITEM_ACCESS");
        _;
    }

    function _grantAllItemRoles(address to_, uint item_id_) private {
        grantItemAccess(to_, item_id_, 'add_sources');
        grantItemAccess(to_, item_id_, 'update_item');
        grantItemAccess(to_, item_id_, 'update_meta');
    }

    function grantItemAccess(address check_, uint item_id_, string memory role_) public onlyRole(MANAGER) {
        _item_roles[item_id_][role_][check_] = true;
    }

    function revokeItemAccess(address check_, uint item_id_, string memory role_) public onlyRole(MANAGER) {
        delete(_item_roles[item_id_][role_][check_]);
    }

    function hasItemAccess(address check_, uint item_id_, string memory role_) public view returns(bool has_){
        has_ = (_item_roles[item_id_][role_][check_] || hasRole(MANAGER, check_));
        if(hasAuxHandler())
            has_ = ICatalogueAuxHandler(getAddress('aux_handler')).filterHasItemAccess(has_, check_, item_id_, role_);
        return has_;
    }



    /**
    ***********************************
    || SOURCES
    ***********************************
    */


    function _addSource(uint item_id_, string memory source_) private {
        _items[item_id_].sources.push(source_);
        emit sourceAdded(item_id_, source_);
    }

    function addSource(uint item_id_, string memory source_) public onlyItemRole(item_id_, 'add_sources') {
        _addSource(item_id_, source_);
    }

    function addSources(uint item_id_, string[] memory sources_) public onlyItemRole(item_id_, 'add_sources') {
        for (uint256 i = 0; i < sources_.length; i++) {
            _addSource(item_id_, sources_[i]);
        }
    }

    function updateItem(uint item_id_, string memory name_, string memory creator_, string memory checksum_) public onlyItemRole(item_id_, 'update_item') {
        _items[item_id_].name = name_;
        _items[item_id_].creator = creator_;
        _items[item_id_].checksum = checksum_;
        emit itemUpdated(item_id_);
    }

    function updateItemName(uint item_id_, string memory name_) public onlyItemRole(item_id_, 'update_item') {
        _items[item_id_].name = name_;
        emit itemUpdated(item_id_);
    }

    function updateItemCreator(uint item_id_, string memory creator_) public onlyItemRole(item_id_, 'update_item') {
        _items[item_id_].creator = creator_;
        emit itemUpdated(item_id_);
    }

    function updateItemChecksum(uint item_id_, string memory checksum_) public onlyItemRole(item_id_, 'update_item') {
        _items[item_id_].checksum = checksum_;
        emit itemUpdated(item_id_);
    }



    /**
    ***********************************
    || META
    ***********************************
    */

    /// @dev private function to update meta for item_id_
    function _updateMeta(uint item_id_, string memory key_, string memory value_) private {
        _meta[item_id_][key_] = value_;
        emit metaUpdated(item_id_, key_, value_);
    }

    /// @dev update meta for item_id_
    function updateMeta(uint item_id_, ICatalogue.Meta[] memory meta_) public onlyItemRole(item_id_, 'update_meta') {
        for(uint256 i = 0; i < meta_.length; i++) {
            _updateMeta(item_id_, meta_[i].key, meta_[i].value);
        }
    }

    /// @dev get meta for item_id_
    function getMeta(uint item_id_, string memory key_) public view returns(string memory) {
        require(itemExists(item_id_), "INVALID_ITEM");
        return _meta[item_id_][key_];
    }

    /// @dev private _delete meta for item_id_
    function _deleteMeta(uint item_id_, string memory key_) private {
        string memory value_ = _meta[item_id_][key_];
        delete(_meta[item_id_][key_]);
        emit metaDeleted(item_id_, key_, value_);
    }

    /// @dev delete meta for item_id_
    function deleteMeta(uint item_id_, string[] memory keys_) public onlyItemRole(item_id_, 'update_meta') {
        for (uint256 i = 0; i < keys_.length; i++) {
            _deleteMeta(item_id_, keys_[i]);
        }
    }


}
