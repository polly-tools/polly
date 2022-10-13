//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import '@openzeppelin/contracts/utils/introspection/ERC165.sol';
import '@polly-tools/core/contracts/Polly.sol';
import '@polly-tools/core/contracts/PollyAux.sol';
import '@polly-tools/module-meta/contracts/Meta.sol';



/// @title IERC2981Royalties
/// @dev Interface for the ERC2981 - Token Royalty standard
interface IERC2981Royalties {
    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param id_ - the NFT asset queried for royalty information
    /// @param value_ - the sale price of the NFT asset specified by id_
    /// @return receiver_ - address of who should be sent the royalty payment
    /// @return amount_ - the royalty payment amount for value sale price
    function royaltyInfo(uint256 id_, uint256 value_)
        external
        view
        returns (address receiver_, uint256 amount_);
}



contract PollyToken is PollyAuxParent, ERC165, IERC2981Royalties {

  struct MetaEntry {
    string _key;
    Polly.Param _value;
  }

  event TokenCreated(uint id);

  Meta internal _meta;

  mapping(uint => bool) private _created;
  mapping(uint => uint) internal _supply;
  uint internal _token_count;

  function _setMetaHandler(address handler_) internal {
    require(address(_meta) == address(0), 'META_HANDLER_SET');
    _meta = Meta(handler_);
  }

  function getMetaHandler() public view returns (Meta) {
    return _meta;
  }


  /// @dev create a new token
  function _createToken(MetaEntry[] memory meta_) internal returns (uint) {

    uint id_ = _token_count+1;

    if(_hasHook('beforeCreateToken')){
      (id_, meta_) = _getAux('beforeCreateToken').beforeCreateToken(address(this), id_, meta_);
    }

    _batchSetMetaForId(id_, meta_);
    _created[id_] = true;
    _token_count++;

    if(_hasHook('afterCreateToken')){
      _getAux('afterCreateToken').afterCreateToken(address(this), id_);
    }

    emit TokenCreated(id_);
    return id_;

  }


  function _getAux(string memory hook_) internal view returns(PollyTokenAux) {
    return PollyTokenAux(_aux_hooks[hook_]);
  }


  function _uri(uint id_) internal view returns (string memory) {

    if(_hasHook('tokenURI')) {
      return _getAux('tokenURI').tokenURI(address(this), id_);
    }
    else {
      return _meta.getString(id_, 'tokenURI');
    }

  }


  function image(uint id_) public view returns (string memory) {
    if(_hasHook('tokenImage')) {
      return _getAux('tokenImage').tokenImage(address(this), id_);
    }
    else {
      return _meta.getString(id_, 'tokenImage');
    }
  }

  function tokenExists(uint id_) public view returns (bool) {
    return _created[id_];
  }


  /// @dev get the token by id
  /// @param id_ the id of the token
  function getTokenMeta(uint id_, string[] memory keys_) public view returns (MetaEntry[] memory) {
    MetaEntry[] memory meta_ = new MetaEntry[](keys_.length);
    for(uint i=0; i<keys_.length; i++){
      meta_[i] = MetaEntry(keys_[i], _meta.get(id_, keys_[i]));
    }
    return meta_;
  }


  /// @dev get the contract metadata uri
  function contractURI() public view returns(string memory) {
    if(_hasHook('contractURI')) {
      return _getAux('contractURI').contractURI(address(this));
    }
    else {
      return _meta.getString(0, 'contractURI');
    }
  }



  /// @dev get the royalty info
  /// @param id_ the id of the token
  /// @param value_ the value of the sale
  function royaltyInfo(uint id_, uint value_) public view override returns (address receiver_, uint amount_) {

    if(_hasHook('royaltyInfo')) {
      return _getAux('royaltyInfo').royaltyInfo(address(this), id_, value_);
    }

    return (address(0), 0);

  }



  /*
  META
  */

  /// @dev batch set meta for id
  /// @param id_ the id of the token
  /// @param meta_ the meta of the token
  function _batchSetMetaForId(uint id_, MetaEntry[] memory meta_) internal {
    for(uint i = 0; i < meta_.length; i++) {
      _meta.set(id_, meta_[i]._key, meta_[i]._value);
    }
  }


  /// Override
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool){
      return interfaceId == type(IERC2981Royalties).interfaceId;
  }


}



abstract contract PollyTokenAux is PollyAux {

  string[] private _aux_available_hooks = [
    "beforeCreateToken",
    "afterCreateToken",
    "beforeMint1155",
    "afterMint1155",
    "beforeMint721",
    "afterMint721",
    "tokenImage",
    "tokenURI",
    "contractURI",
    "royaltyInfo"
  ];


  function beforeCreateToken(address, uint id_, PollyToken.MetaEntry[] memory meta_) external virtual returns(uint, PollyToken.MetaEntry[] memory) {return (id_, meta_);}
  function afterCreateToken(address parent_, uint id_) external virtual {}
  function beforeMint721(address parent_, uint id_, bool pre_, Msg memory msg_) external virtual {} // For ERC721
  function afterMint721(address parent_, uint id_, bool pre_, Msg memory msg_) external virtual {} // For ERC721
  function beforeMint1155(address parent_, uint id_, uint amount_, bool pre_, Msg memory msg_) external virtual {} // For ERC1155
  function afterMint1155(address parent_, uint id_, uint amount_, bool pre_, Msg memory msg_) external virtual{} // For ERC1155
  function tokenImage(address parent_, uint id_) external view virtual returns (string memory){}
  function tokenURI(address parent_, uint id_) external view virtual returns (string memory){}
  function contractURI(address parent_) external view virtual returns (string memory){}
  function royaltyInfo(address parent_, uint id_, uint value_) external view virtual returns (address receiver, uint royaltyAmount){}

}
