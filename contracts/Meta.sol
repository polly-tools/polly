//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Polly.sol";
import "./Initializable.sol";

interface IMeta is IAccessControl, IInitializable {

  function init(IPolly.Instance memory instance_) external;

  function updateMeta(string memory domain_, uint item_id_, string[] memory keys_, string[] memory values_) external;
  function getMeta(string memory domain_, uint item_id_, string memory key_) external view returns(string memory);
  function deleteMeta(string memory domain_, uint item_id_, string[] memory keys_) external;

}


contract Meta is AccessControl, Initializable {

  event metaUpdated(string indexed _key, string indexed value);
  event metaDeleted(string indexed _key, string indexed value);

  /// @dev MANAGER_ROLE allow addresses to add items to the catalogue
  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

  mapping(string => mapping(uint => mapping(string => string))) private _meta; /// @dev domain => item_id => (key => value)


  function init(IPolly.Instance memory instance_) public {

    super.init();

    _grantRole(DEFAULT_ADMIN_ROLE, instance_.owner);
    _grantRole(MANAGER_ROLE, instance_.owner);

    _grantRole(MANAGER_ROLE, instance_.coll);
    _grantRole(MANAGER_ROLE, instance_.cat);

  }


  /// @dev private function to update meta for item_id_
  function _updateMeta(string memory domain_, uint item_id_, string memory key_, string memory value_) private {
    _meta[domain_][item_id_][key_] = value_;
    emit metaUpdated(key_, value_);
  }

  /// @dev update meta for item_id_
  function updateMeta(string memory domain_, uint item_id_, string[] memory keys_, string[] memory values_) public onlyRole(MANAGER_ROLE) {

    require(keys_.length == values_.length, "KEY_VALUE_LENGTH_MISMATCH");

    for(uint256 i = 0; i < keys_.length; i++) {
      _updateMeta(domain_, item_id_, keys_[i], values_[i]);
    }

  }

  /// @dev get meta for item_id_
  function getMeta(string memory domain_, uint item_id_, string memory key_) public view returns(string memory) {
    return _meta[domain_][item_id_][key_];
  }

  /// @dev private _delete meta for item_id_
  function _deleteMeta(string memory domain_, uint item_id_, string memory key_) private {
    string memory value_ = _meta[domain_][item_id_][key_];
    delete(_meta[domain_][item_id_][key_]);
    emit metaDeleted(key_, value_);
  }

  /// @dev delete meta for item_id_
  function deleteMeta(string memory domain_, uint item_id_, string[] memory keys_) public onlyRole(MANAGER_ROLE) {
    for (uint256 i = 0; i < keys_.length; i++) {
      _deleteMeta(domain_, item_id_, keys_[i]);
    }
  }

}
