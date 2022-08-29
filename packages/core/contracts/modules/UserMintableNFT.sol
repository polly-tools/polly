//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../Polly.sol";
import "../PollyAux.sol";


/**
 * @title Nft
 * @notice Nft is a Polly module that allows you to create and manage NFTs.
 */

contract GenerativeTokens is ERC721, PollyModule {


  modifier onlyParent(){
    require(msg.sender == address(this));
    _;
  }

  constructor() ERC721('', '') PollyModule() {

  }

  function moduleInfo() public pure returns (IPollyModule.Info memory) {
    return IPollyModule.Info("GenerativeTokens", false);
  }

  function tokenUri() public pure returns (string memory) {
    return "";
  }

  function contractUri() public pure returns (string memory) {
    return "";
  }

  function mint(){
    beforeMint(msg);

    afterMint(msg);
  }

}


contract GenerativeTokenGenerator is PollyModule {
  function beforeMint(uint _uint, msg message_) external virtual;
  function afterMint(uint _uint, msg message_) external virtual;
  function image(uint _id) public virtual returns (uint _tokenId);
  function json(uint _id) public virtual returns (string memory);
}


contract NftConfigurator is PollyConfigurator {

  function info() public pure override returns (string memory, string[] memory, string[] memory) {

    string[] memory inputs_ = new string[](2);
    inputs_[0] = "string.name.the name of the token";
    inputs_[1] = "string.symbol.the symbol of the token";

    string[] memory outputs_ = new string[](1);

    return "Simple NFT contract to allow minting of NFTs", ["Nft"], ["Nft"];

  }

  function run(Polly polly_, address for_, PollyConfigurator.Param[] memory) public override returns(PollyConfigurator.Param[] memory){

  }



}
