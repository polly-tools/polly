//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/Strings.sol";
import "../Polly.sol";
import "./Collection.sol";

/**
*
* CHAINS
*
**/


contract Chains is CollectionAux, PollyModule {


    struct Chain {
        address admin;
        uint id;
        uint edition;
        uint node;
        address contributor;
        uint nodes;
        uint node_supply;
        uint admin_supply;
        bool moderation;
    }


    struct Node {
        uint chain;
        string name;
        string creator;
        string url;
        string checksum;
        address next;
    }


    uint private constant _default_nodes = 7;
    uint private _chain_ids;
    mapping(uint => Chain) private _chains;
    mapping(uint => Node) private _node_submissions;
    mapping(uint => mapping(uint => address)) _node_contributors; // (chain => (node => contributor))
    mapping(uint => uint) private _edition_chain;


    modifier onlyContributorOrAdmin(uint chain_id_){
        Chain memory chain_ = _chains[chain_id_];
        require(msg.sender == chain_.contributor || msg.sender == chain_.admin, 'ONLY_CONTRIBUTOR_OR_ADMIN');
        _;
    }

    modifier onlyAdmin(uint chain_id_){
        require(msg.sender == _chains[chain_id_].admin, 'ONLY_ADMIN');
        _;
    }

    modifier onlyContributor(uint chain_id_){
        require(msg.sender == _chains[chain_id_].contributor, 'ONLY_CONTRIBUTOR');
        _;
    }












/**

 _|_|_|      _|_|    _|        _|    _|      _|
 _|    _|  _|    _|  _|        _|      _|  _|
 _|_|_|    _|    _|  _|        _|        _|
 _|        _|    _|  _|        _|        _|
 _|          _|_|    _|_|_|_|  _|_|_|_|  _|

*/

    constructor() PollyModule(){
      _setConfigurator(address(new ChainsConfigurator()));
    }


    /// @dev return module info -> (name, location, clone)
    function moduleInfo() public pure returns(IPollyModule.Info memory){
        return IPollyModule.Info("chains", true);
    }


    /// @dev defines what hooks are used in this aux contract
    function getHooks() public pure override returns(string[] memory hooks_){
        hooks_ = new string[](1);
        hooks_[0] = 'filterGetEdition';
        return hooks_;
    }


    function _getCollection() private view returns(ICollection){
        address coll_0x_ = getAddress('collection');
        require(coll_0x_ != address(0), "Please set collection address");
        return ICollection(coll_0x_);
    }

    function _getCatalogue() private view returns(ICatalogue){
        address cat_0x_ = _getCollection().getAddress('catalogue');
        require(cat_0x_ != address(0), "Please set catalogue address");
        return ICatalogue(cat_0x_);
    }















/**

   _|_|_|    _|_|    _|        _|        _|_|_|_|    _|_|_|  _|_|_|_|_|  _|_|_|    _|_|    _|      _|
 _|        _|    _|  _|        _|        _|        _|            _|        _|    _|    _|  _|_|    _|
 _|        _|    _|  _|        _|        _|_|_|    _|            _|        _|    _|    _|  _|  _|  _|
 _|        _|    _|  _|        _|        _|        _|            _|        _|    _|    _|  _|    _|_|
   _|_|_|    _|_|    _|_|_|_|  _|_|_|_|  _|_|_|_|    _|_|_|      _|      _|_|_|    _|_|    _|      _|


*/


    function _getSupply(Chain memory chain_) private view returns(uint){
        uint base_ = chain_.node*chain_.node_supply;
        if(chain_.node >= chain_.nodes)
            base_ = base_+chain_.admin_supply;
        return base_ - ICollection(getAddress('collection')).totalSupply(chain_.edition);
    }


    function filterGetEdition(ICollection.Edition memory edition_) public view returns(ICollection.Edition memory){

        /// @dev get chain for edition
        if(_chains[_edition_chain[edition_.id]].admin == address(0))
            return edition_;

        Chain memory chain_ = _chains[_edition_chain[edition_.id]];

        edition_.name = string(abi.encodePacked('#', Strings.toString(edition_.id)));
        edition_.recipient = getCurrentChainRecipient(chain_.id);

        edition_.supply = _getSupply(chain_);

        if(chain_.node < chain_.nodes)
            edition_.finalized = false;

        return edition_;

    }


















/**

   _|_|_|  _|    _|    _|_|    _|_|_|  _|      _|    _|_|_|
 _|        _|    _|  _|    _|    _|    _|_|    _|  _|
 _|        _|_|_|_|  _|_|_|_|    _|    _|  _|  _|    _|_|
 _|        _|    _|  _|    _|    _|    _|    _|_|        _|
   _|_|_|  _|    _|  _|    _|  _|_|_|  _|      _|  _|_|_|


*/


    /// PRIVATE

    function _updateChain(Node memory node_) private {

        require(!chainCompleted(node_.chain), 'CHAIN_COMPLETED');

        ICollection coll_ = _getCollection();
        ICatalogue cat_ = _getCatalogue();

        // Get chain and edition
        Chain memory chain_ = _chains[node_.chain];
        ICollection.Edition memory edition_ = coll_.getEdition(chain_.edition, true);

        // Update the catalogue
        uint item_id_ = edition_.items[chain_.node];
        cat_.updateItem(item_id_, node_.name, node_.creator, node_.checksum);
        cat_.addSource(item_id_, node_.url);

        // Pass on the chain
        _setContributor(node_.chain, node_.next);
        _setNodeContributor(node_.chain, chain_.node+1, msg.sender);
        _incrementNode(node_.chain);

    }

    function _setContributor(uint chain_id_, address contributor_) private {
        _chains[chain_id_].contributor = contributor_;
    }


    /// PUBLIC

    function initChain(string memory creator_, address initiator_, address admin_, uint nodes_, uint node_supply_, uint admin_supply_, uint price_, bool moderation_) public onlyRole(MANAGER){

        address coll_0x_ = getAddress('collection');
        require(coll_0x_ != address(0), "Please set collection address");

        ICollection.EditionInput memory edition_ = ICollection.EditionInput(
            "",
            creator_,
            price_,
            (node_supply_*nodes_)+admin_supply_,
            address(0),
            new ICatalogue.Item[](nodes_)
        );

        uint edition_id_ = ICollection(coll_0x_).createEdition(edition_);

        _chain_ids++;
        _chains[_chain_ids] = Chain(
            admin_,
            _chain_ids,
            edition_id_,
            0, // Node 0 to begin
            initiator_,
            nodes_,
            node_supply_,
            admin_supply_,
            moderation_
        );

        _edition_chain[edition_id_] = _chain_ids;

    }


    function getChain(uint chain_id_) public view returns(Chain memory){
        return _chains[chain_id_];
    }

    function getChainCount() public view returns(uint){
        return _chain_ids;
    }

    function getCurrentChainRecipient(uint chain_id_) public view returns(address) {

        Chain memory chain_ = getChain(chain_id_);
        uint supply_ = ICollection(getAddress('collection')).totalSupply(chain_.edition);
        uint supply_node_ = (supply_/chain_.node_supply)+1;

        // console.log('');
        // console.log('---------');
        // console.log(chain_.nodes, 'MAX_NODES');
        // console.log(supply_node_, 'SUPPLY_NODE');

        if(supply_node_ <= chain_.nodes)
            return _node_contributors[chain_.id][supply_node_];
        return chain_.admin;


    }















/**

 _|      _|    _|_|    _|_|_|    _|_|_|_|    _|_|_|
 _|_|    _|  _|    _|  _|    _|  _|        _|
 _|  _|  _|  _|    _|  _|    _|  _|_|_|      _|_|
 _|    _|_|  _|    _|  _|    _|  _|              _|
 _|      _|    _|_|    _|_|_|    _|_|_|_|  _|_|_|


*/



    function submitNode(Node memory node_) public onlyContributor(node_.chain) {

        Chain memory chain_ = _chains[node_.chain];

        if(chain_.moderation){ // Chain moderation is ON and the node is held for chain admin approval
            _node_submissions[node_.chain] = node_;
        }
        else { // Chain moderation is OFF and the node is added right away
            _updateChain(node_);
        }

    }

    function getNodeSubmission(uint chain_id_) public view returns(Node memory) {
        return _node_submissions[chain_id_];
    }

    function approveNodeSubmission(uint chain_id_) public onlyAdmin(chain_id_) {
        _approveNodeSubmission(chain_id_);
    }

    function rejectNodeSubmission(uint chain_id_, bool take_over_) public onlyAdmin(chain_id_) {
        _rejectNodeSubmission(chain_id_);
        if(take_over_)
            _setContributor(chain_id_, msg.sender);
    }

    function setContributor(uint chain_id_, address contributor_) public onlyAdmin(chain_id_){
        _setContributor(chain_id_, contributor_);
    }

    function _rejectNodeSubmission(uint chain_id_) public onlyAdmin(chain_id_) {
        _node_submissions[chain_id_] = Node(0, '', '', '', '', address(0));
    }

    function _approveNodeSubmission(uint chain_id_) private {

        Node memory sub_ = _node_submissions[chain_id_];

        // TODO: Assert if already submitted

        _updateChain(Node(
            sub_.chain,
            sub_.name,
            sub_.creator,
            sub_.url,
            sub_.checksum,
            sub_.next
        ));

        // Reset node
        _node_submissions[chain_id_] = Node(0, '', '', '', '', address(0));

    }


    function chainCompleted(uint chain_id_) public view returns(bool){
        return (_chains[chain_id_].node >= _chains[chain_id_].nodes);
    }


    /// PRIVATE


    function _setNodeContributor(uint chain_, uint node_, address contributor_) private {
        _node_contributors[chain_][node_] = contributor_;
    }

    function _incrementNode(uint chain_id_) private {
        _chains[chain_id_].node++;
    }

    function _decrementNode(uint chain_id_) private {
        _chains[chain_id_].node--;
    }



}


contract ChainsConfigurator is PollyConfigurator {


    struct Config {
        address collection;
        address catalogue;
        address aux_handler;
    }

    function info() public pure override returns(string memory, string[] memory, string[] memory) {
      return ('Chains', new string[](0), new string[](0));
    }

    function run(Polly polly_, address for_, PollyConfigurator.Param[] memory) public override returns(PollyConfigurator.Param[] memory){

        Param[] memory coll_input_params_ = new Param[](1);
        coll_input_params_[0] = Param('', 0, true, address(0));// Include aux handler
        PollyConfigurator.Param[] memory dep_params_ = polly_.configureModule(
          'collection',
          0,
          coll_input_params_,
          false, /*Don't store*/
          '' /*No custom name*/
        );

        Catalogue cat_ = Catalogue(dep_params_[0]._address);
        Collection coll_ = Collection(dep_params_[1]._address);
        CollectionAuxHandler coll_aux_ = CollectionAuxHandler(dep_params_[2]._address);

        Chains chains_ = Chains(polly_.cloneModule('chains', 0));

        chains_.grantRole(DEFAULT_ADMIN_ROLE, for_);
        chains_.grantRole(MANAGER, for_);

        chains_.setAddress('collection', address(coll_));
        coll_.grantRole(MANAGER, address(chains_));
        cat_.grantRole(MANAGER, address(chains_));
        coll_aux_.addAux(address(chains_));

        PollyConfigurator.Param[] memory rparams_ = new PollyConfigurator.Param[](4);

        rparams_[0] = PollyConfigurator.Param('', 0, false, address(cat_));
        rparams_[1] = PollyConfigurator.Param('', 0, false, address(coll_));
        rparams_[2] = PollyConfigurator.Param('', 0, false, address(coll_aux_));
        rparams_[3] = PollyConfigurator.Param('', 0, false, address(chains_));

        return rparams_;

    }

}
