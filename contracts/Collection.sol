//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./Polly.sol";
import "./Catalogue.sol";
import "./Aux.sol";
import "./Meta.sol";
import "./Initializable.sol";

import "hardhat/console.sol";

interface ICollection {

    struct Edition {
        uint id;
        string name;
        string creator;
        uint price;
        uint supply;
        address recipient;
        uint[] items;
    }

    struct EditionInput {
        string name;
        string creator;
        uint price;
        uint supply;
        address recipient;
        ICatalogue.ItemInput[] items;
    }

    function init(IPolly.Instance memory instance_) external;
    function setCatalogueAddress(address meta_) external;
    function getCatalogueAddress() external view returns(address);

    function createEdition(ICollection.EditionInput memory edition_input_) external;
    function getEdition(uint edition_id_) external view returns(Edition memory);
    function addItems(uint edition_id_) external;
    function removeItem(uint edition_id_, uint index_) external;

    function addAux(address aux_) external;

}


contract Collection is ERC1155, ERC1155Supply, AccessControl, Initializable {

    bool _init = false;

    ICatalogue private _cat;
    IMeta private _meta;
    IAuxHandler private _aux_handler;

    mapping(string => address) private _hooks;

    uint private _edition_ids;
    mapping(uint => ICollection.Edition) private _editions;
    mapping(uint => bool) private _released;
    mapping(uint => bool) private _finalized;

    string private _coll_id = '';

    /// @dev MANAGER_ROLE allow addresses to use the label contract
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    constructor() ERC1155("") {
        // _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // _grantRole(MANAGER_ROLE, msg.sender);
    }

    function init(IPolly.Instance memory instance_) public {

        super.init();

        _grantRole(DEFAULT_ADMIN_ROLE, instance_.owner);
        _grantRole(MANAGER_ROLE, instance_.owner);
        _grantRole(MANAGER_ROLE, instance_.aux_handler);
        _grantRole(MANAGER_ROLE, instance_.meta);
        _grantRole(MANAGER_ROLE, instance_.cat);

        _cat = ICatalogue(instance_.cat);
        _meta = IMeta(instance_.meta);
        _aux_handler = IAuxHandler(instance_.aux_handler);

    }

    function getId() public view returns(string memory){
        return _coll_id;
    }

    function getCatalogueAddress() public view returns(address){
      return address(_cat);
    }

    ////////////////////////////////////////////////////
    /// EDITIONS
    ////////////////////////////////////////////////////

    function createEdition(
      ICollection.EditionInput memory edition_input_
    )
    public onlyRole(MANAGER_ROLE) {

        uint[] memory items_ = new uint[](edition_input_.items.length);
        uint item_id_;

        for(uint i = 0; i < edition_input_.items.length; i++) {
            item_id_ = _cat.createItem(edition_input_.items[i]);
            items_[i] = item_id_;
        }

        ICollection.Edition memory edition_ = ICollection.Edition(
            _edition_ids,
            edition_input_.name,
            edition_input_.creator,
            edition_input_.price,
            edition_input_.supply,
            edition_input_.recipient,
            items_
        );

        _aux_handler.actionBeforeCreateEdition(edition_, msg.sender);

        _edition_ids++;
        _editions[_edition_ids] = edition_;

        _aux_handler.actionAfterCreateEdition(_editions[_edition_ids], msg.sender);

    }


    function getEdition(
      uint edition_id_
    )
    public view returns(ICollection.Edition memory) {
      return _editions[edition_id_];
    }


    function addItem(
      uint edition_id_,
      ICatalogue.Item memory item_
    )
    public onlyRole(MANAGER_ROLE) {
      require(!isFinalized(edition_id_), 'EDITION_FINALIZED');

    }


    function removeItem(
      uint edition_id_,
      uint index_
    )
    public onlyRole(MANAGER_ROLE) {
      require(!isFinalized(edition_id_), 'EDITION_FINALIZED');

    }


    function isFinalized(
      uint edition_id_
    ) public view returns(bool){
      return _finalized[edition_id_];
    }


    function isReleased(
      uint edition_id_
    ) public view returns(bool){
      return _released[edition_id_];
    }

    /// @dev returns filtered supply as long a it is below max
    function getAvailable(
      uint edition_id_
    ) public view returns(uint){
      uint max_ = _editions[edition_id_].supply - totalSupply(edition_id_);
      uint avail_ = _aux_handler.filterGetAvailable(max_, edition_id_);
      return avail_ <= max_ ? avail_ : max_;
    }

    /// @dev returns filtered price
    function isValidPrice(uint edition_id_, uint price_) public view returns(bool) {
      bool valid_ = (_editions[edition_id_].price == price_);
      valid_ = _aux_handler.filterIsValidPrice(valid_, edition_id_, price_);
      return valid_;
    }


    function mint(
      uint edition_id_
    )
    public payable {

      require(isReleased(edition_id_), "UNRELEASED");
      require(isValidPrice(edition_id_, msg.value), "INVALID_PRICE");
      require((getAvailable(edition_id_) > 0), "NOT_AVAILABLE");

      _aux_handler.actionBeforeMint(edition_id_, msg.sender);

      (bool sent, bytes memory data) =  _editions[edition_id_].recipient.call{value: msg.value}("");
      require(sent, "FAILED TO SEND ETH");

      _mintFor(msg.sender, edition_id_);

      _aux_handler.actionAfterMint(edition_id_, msg.sender);

    }


    function _mintFor(
      address for_,
      uint edition_id_
    ) private {
      _mint(for_, edition_id_, 1, "");
    }


    function uri(uint edition_id_) public view override returns(string memory uri_){
      return _aux_handler.filterGetURI(uri_, edition_id_);
    }

    // Overrides
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
    internal
    virtual
    override (ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
    public
    view
    override(ERC1155, AccessControl)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


}

