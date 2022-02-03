//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import './Collection.sol';

interface IHooks {

  // ACTIONS
  function actionBeforeCreateEdition(ICollection.Edition memory edition_, address sender_) external;
  function actionAfterCreateEdition(ICollection.Edition memory edition_, address sender_) external;
  function actionBeforeMint(uint edition_id_, address sender_) external;
  function actionAfterMint(uint edition_id_, address sender_) external;

  // FILTERS
  function filterGetURI(string memory uri_, uint edition_id_) external view returns(string memory);
  function filterGetArtwork(string memory artwork_, uint edition_id_) external view returns(string memory);
  function filterGetAvailable(uint available, uint edition_id_) external view returns(uint);
  function filterIsReleased(bool released_, uint edition_id_) external view returns(bool);
  function filterIsFinalized(bool finalized_, uint edition_id_) external view returns(bool);
  function filterIsValidPrice(bool valid_, uint edition_id_, uint price_) external view returns(bool);

}
