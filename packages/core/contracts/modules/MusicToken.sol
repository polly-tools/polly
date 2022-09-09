//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import '../Polly.sol';
import '../PollyConfigurator.sol';
import './shared/PollyToken.sol';


contract MusicToken is PMClone, PollyTokenAux {
  string public constant override PMNAME = "MusicToken";
  uint256 public constant override PMVERSION = 1;
  string public constant override PMINFO =
    "MusicToken | create and set mint of music tokens";

  constructor() {
    _setConfigurator(address(new MusicTokenConfigurator()));
  }

  function hooks()
    public
    view
    virtual
    override
    returns (PollyAux.Hook[] memory)
  {
    Hook[] memory hooks_ = new Hook[](6);

    hooks_[0] = Hook("afterCreateToken", false);
    hooks_[1] = Hook("beforeMint", false);
    hooks_[2] = Hook("afterMint", false);
    hooks_[3] = Hook("getToken", false);
    hooks_[4] = Hook("tokenURI", true);
    hooks_[5] = Hook("contractURI", false);

    return hooks_;
  }

  function tokenURI(uint id_) public view override returns (string memory) {
    return "MUSIC TOKEN URI";
  }


}


contract MusicTokenConfigurator is PollyConfigurator {

  string public constant override FOR_PMNAME = 'MusicToken';
  uint public constant override FOR_PMVERSION = 1;

  function inputs() public pure override returns (string[] memory) {
    string[] memory inputs_ = new string[](1);

    inputs_[0] = string(abi.encodePacked(
      '{',
        '"string": {',
          '"label": "Token type", "input": {',
            '"Polly721": "ERC721", "Polly1155": "ERC1155"}, "info": "What type of music token do you want to create?"',
          '}',
        '},',
        '"uint": {',
          '"label": "Token ID", "input": "number", "info": "The ID of the token to create"',
        '},',
      '}')
      );

    return inputs_;
  }

  function outputs() public pure override returns (string[] memory) {
    string[] memory outputs_ = new string[](3);
    outputs_[0] = '{"type": "module", "value": "MusicToken", "info": "The address of the token"}';
    outputs_[1] = '{"type": "address", "value": "token module", "info": "The address of the token module - either erc721 or erc1155"}';
    outputs_[2] = '{"type": "module", "value": "MetaForIds", "info": "The address of the meta module"}';
    return new string[](0);
  }

  function run(Polly polly_, address for_, Polly.Param[] memory inputs_) public override returns(Polly.Param[] memory){

    Polly.Param[] memory rparams_ = new Polly.Param[](1);

    /// TODO - check if the token type is valid
    // TokenModule = PollyToken(polly_.cloneModule(inputs_[0]._string, inputs_[0]._string));

    MusicToken music_token_ = MusicToken(polly_.cloneModule(FOR_PMNAME, FOR_PMVERSION));
    rparams_[0]._address = address(music_token_);


    /// SET PERMISSIONS
    music_token_.grantRole(music_token_.DEFAULT_ADMIN_ROLE(), for_);
    music_token_.grantRole(music_token_.MANAGER(), for_);


    return rparams_;

  }

}
