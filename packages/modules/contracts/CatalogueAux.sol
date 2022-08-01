//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@polly-os/core/contracts/PollyModule.sol";
import "@polly-os/core/contracts/PollyAux.sol";
import "./Catalogue.sol";


interface ICatalogueHooks {
    function filterHasItemAccess(bool has_, address check_, uint item_id_, string memory access_) external view returns(bool);
}

interface ICatalogueAux is ICatalogueHooks, IPollyAux {}
interface ICatalogueAuxHandler is ICatalogueHooks, IPollyAuxHandler {}


contract CatalogueAuxHandler is PollyModule, PollyAuxHandler {


    function getInfo() public pure returns(IPollyModule.Info memory){
        return IPollyModule.Info('polly.CatalogueAuxHandler', true);
    }

    function filterHasItemAccess(bool has_, address check_, uint item_id_, string memory access_) public view onlyRole(MANAGER) returns(bool) {
        address[] memory hooks_ = getAuxForHook('filterHasItemAccess');
        for(uint256 i = 0; i < hooks_.length; i++)
            has_ = ICatalogueAux(hooks_[i]).filterHasItemAccess(has_, check_, item_id_, access_);
        return has_;
    }

}


abstract contract CatalogueAux is PollyAux {

}