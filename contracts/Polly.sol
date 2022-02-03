//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "./Collection.sol";
import "./Catalogue.sol";
import "./Meta.sol";
import "./Aux.sol";


interface IPolly {

  struct Instance {
    address owner;
    address coll;
    address cat;
    address meta;
    address aux_handler;
  }

}

contract Polly {


    mapping(string => IPolly.Instance) private _instances;
    mapping(address => string) private _instance_ids;
    address private _coll;
    address private _cat;
    address private _meta;
    address private _aux_handler;

    constructor() {

      _coll = address(new Collection());
      _cat = address(new Catalogue());
      _meta = address(new Meta());
      _aux_handler = address(new AuxHandler());

    }


    /// @dev Creates a Polly instance for the calling address
    /// @param id_ a string identification for the collection
    /// @param aux_ auxiliaries to attach at instance creation

    function createInstance(
        string memory id_,
        address[] memory aux_
    ) public {

        require(!instanceExists(id_), 'Collection with that id already exists');

        IPolly.Instance memory instance_ = IPolly.Instance(
            msg.sender,
            Clones.clone(_coll),
            Clones.clone(_cat),
            Clones.clone(_meta),
            Clones.clone(_aux_handler)
        );

        ICollection(instance_.coll).init(instance_);
        ICatalogue(instance_.cat).init(instance_);
        IMeta(instance_.meta).init(instance_);
        IAuxHandler(instance_.aux_handler).init(instance_, aux_);

        _instances[id_] = instance_;

    }

    /// @notice Get the instance address for collection with id_
    /// @param id_ a string identification for the collection
    /// @return address of the instance;

    function getInstance(
        string memory id_
    ) public view returns(IPolly.Instance memory){
        require(instanceExists(id_), 'Instance does not exist');
        return _instances[id_];
    }


    /// @notice Determine wether a collection instance exists or not
    /// @param id_ a string identification for the collection
    /// @return true if exists, false if not

    function instanceExists(
        string memory id_
    ) public view returns(bool){
        return !(_instances[id_].coll == address(0));
    }



}
