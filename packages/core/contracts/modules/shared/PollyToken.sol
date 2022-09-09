//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import '../../Polly.sol';
import '../../PollyAux.sol';
import '../MetaForIds.sol';

contract PollyToken is PollyAuxParent {

  struct Meta {
    string _key;
    Polly.Param _value;
  }

  event TokenCreated(uint id);

  MetaForIds internal _meta;

  uint internal _token_count;


  function _setMetaHandler(address handler_) internal {
    _meta = MetaForIds(handler_);
  }

  /// @dev create a new token
  function _createToken(Meta[] memory meta_) internal returns (uint) {

    uint id_ = _token_count+1;
    _token_count = id_;

    _batchSetMetaForId(id_, meta_);

    if(_aux_hooks['createToken']){
      _getAux().afterCreateToken(id_);
    }

    emit TokenCreated(id_);
    return id_;

  }


  function _getAux() internal view returns(PollyTokenAux) {
    return PollyTokenAux(_aux);
  }



  function _uri(uint id_) internal view returns (string memory) {
    if(_aux_hooks['tokenURI']) {
      return _getAux().tokenURI(id_);
    }
    else {
      return _meta.getString(id_, 'tokenURI');
    }
  }


  /// @dev get the token by id
  /// @param id_ the id of the token
  function getTokenMeta(uint id_, string[] memory keys_) public view returns (Meta[] memory) {
    Meta[] memory meta_ = new Meta[](keys_.length);
    for(uint i=0; i<keys_.length; i++){
      meta_[i] = Meta(keys_[i], _meta.get(id_, keys_[i]));
    }
    return meta_;
  }


  /// @dev get the contract metadata uri
  function contractURI() public view returns(string memory) {
    if(_aux_hooks['contractURI']) {
      return _getAux().contractURI();
    }
    else {
      return _meta.getString(0, 'contractURI');
    }
  }



  /// Implement Royalty info



  /*
  META
  */

  /// @dev batch set meta for id
  /// @param id_ the id of the token
  /// @param meta_ the meta of the token
  function _batchSetMetaForId(uint id_, Meta[] memory meta_) internal {
    for(uint i = 0; i < meta_.length; i++) {
      _meta.set(id_, meta_[i]._key, meta_[i]._value);
    }
  }

}



abstract contract PollyTokenAux is PollyAux {

  string[] private _aux_available_hooks = [
    "afterCreateToken",
    "beforeMint1155",
    "afterMint1155",
    "beforeMint721",
    "afterMint721",
    "getToken",
    "tokenURI",
    "contractURI"
  ];

  function _availableHooks() internal view returns(Hook[] memory) {
    Hook[] memory hooks_ = new Hook[](_aux_available_hooks.length);
    for(uint i = 0; i < _aux_available_hooks.length; i++) {
      hooks_[i] = Hook(_aux_available_hooks[i], false);
    }
    return hooks_;
  }
  function afterCreateToken(uint id_) external virtual {}
  function beforeMint721(uint id_, Msg memory msg_) external virtual {} // For ERC721
  function afterMint721(uint id_, Msg memory msg_) external virtual {} // For ERC721
  function beforeMint1155(uint id_, uint amount_, Msg memory msg_) external virtual {} // For ERC1155
  function afterMint1155(uint id_, uint amount_, Msg memory msg_) external virtual{} // For ERC1155
  function tokenURI(uint id_) external view virtual returns (string memory){}
  function contractURI() external view virtual returns (string memory){}

}

