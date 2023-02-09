//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@polly-tools/core/contracts/Polly.sol";
import '@polly-tools/core/contracts/PollyConfigurator.sol';

// Hardhat console
import "hardhat/console.sol";

/// @title Token Registry module
/// @author Polly
/// @dev The Token Registry module allows token providers to register tokens

contract TokenRegistry is PMClone {

    /// STRUCTS

    struct Provider {
        string _identifier; // A string identifier for the provider
        address _address; // The address of the provider
        string _function; // The function signature of the provider
        uint _status; // 0 - enabled, 1 - disabled, 2 - banned
    }

    struct Token {
        address _provider;
        uint _id;
    }

    struct TokenInformation {
        uint _id;
        string _meta;
        Provider _provider;
    }


    /// VARIABLES
    uint private _current_id;
    mapping(uint => Token) private _tokens;
    mapping(address => Provider) private _providers;
    mapping(address => mapping(address => bool)) private _provider_controllers;
    mapping(address => mapping(uint => uint)) private _provider_tokens; /// provider => token => id

    /// EVENTS
    event TokenRegistered(
        address indexed _address,
        uint _id
    );

    /// POLLY
    string public constant override PMNAME = 'TokenRegistry';
    uint public constant override PMVERSION = 1;


    /// MODIFIERS

    /// @dev modifier to allow only sender with role 'manager' to call this function
    modifier onlyManager {
        require(hasRole('manager', msg.sender), 'ONLY_MANAGER');
        _;
    }

    modifier onlyProvider(){
      require(_providers[msg.sender]._address != address(0), 'ONLY_PROVIDER');
      _;
    }


    /// CONSTRUCTOR
    constructor() {
      _setConfigurator(address(new TokenRegistryConfigurator()));
    }


    /// PROVIDERS

    /// @dev Register a new provider
    /// @param provider_  The provider to register
    function registerProvider(Provider memory provider_) public onlyManager {
      _providers[provider_._address] = provider_;
    }


    /// @dev set provider status
    /// @param provider_ The provider to set status for
    /// @param status_ The status to set - 0 - enabled, 1 - disabled, 2 - banned
    function setProviderStatus(address provider_, uint status_) public onlyManager {
      require(status_ <= 2, 'INVALID_STATUS');
      _providers[provider_]._status = status_;
    }

    /// @dev Get the provider information
    /// @param address_ The address of the provider
    /// @return The provider information
    function getProvider(address address_) public view returns (Provider memory) {
        return _providers[address_];
    }

    /// @dev add controller to provider
    /// @param provider_ The provider to add the controller to
    /// @param controller_ The controller to add
    function addProviderController(address provider_, address controller_) public onlyManager {
      _provider_controllers[controller_][provider_] = true;
    }

    /// @dev remove controller from provider
    /// @param provider_ The provider to remove the controller from
    /// @param controller_ The controller to remove
    function removeProviderController(address provider_, address controller_) public onlyManager {
      delete _provider_controllers[controller_][provider_];
    }


    /// @dev private function to check provider status
    /// @param provider_ The provider to check the status of
    /// @param status_ The status to check against
    /// @return True if the provider status is equal to the status_ parameter
    function _reqProviderStatus(address provider_, uint status_) private view returns (bool) {
      return _providers[provider_]._status <= status_;
    }


    /// TOKENS

    /// @dev private function to register a token
    /// @param provider_ The provider of the token
    /// @param provider_id_ The id of the token
    function _registerToken(address provider_, uint provider_id_) private returns(uint) {
        _current_id++;
        _tokens[_current_id] = Token(provider_, provider_id_);
        _provider_tokens[provider_][provider_id_] = _current_id;
        console.log(_current_id, provider_, provider_id_, address(this));
        emit TokenRegistered(provider_, provider_id_);
        return _current_id;
    }

    function isValidForProvider(address provider_, address sender_) public view returns(bool){

      if(_providers[provider_]._status != 0)
        return false; // provider is disabled or banned

      if(sender_ != provider_ && !_provider_controllers[sender_][provider_])
        return false; // sender_ is not provider or controller

      return true;

    }

    /// @dev Register a new token
    /// @param provider_id_ The id of the token
    /// @return id the id of the newly registered token
    function registerToken(address provider_, uint provider_id_) public returns(uint) {
      console.log('registerToken', 'isValid', isValidForProvider(provider_, msg.sender));
      if(!isValidForProvider(provider_, msg.sender))
        return 0;

      return _registerToken(provider_, provider_id_);

    }


    /// @dev batch register tokens for a provider
    /// @param provider_ The provider of the tokens
    /// @param ids_ The ids of the tokens
    function batchRegisterTokens(address provider_, uint[] memory ids_) public returns(uint[] memory) {

      if(!isValidForProvider(provider_, msg.sender))
        return new uint[](0);

      uint[] memory result_ = new uint[](ids_.length);
      for(uint i = 0; i < ids_.length; i++){
        result_[i] = _registerToken(provider_, ids_[i]);
      }

      return result_;

    }


    /// @dev check if a token is registered
    /// @param provider_ The provider address
    /// @param provider_id_ The provider token ID
    /// @return True if the token is registered
    function isTokenRegistered(address provider_, uint provider_id_) public view returns(bool) {
      return _provider_tokens[provider_][provider_id_] != 0;
    }


    /// @dev Get the total token count
    /// @return The total token count
    function getTokenCount() public view returns (uint) {
        return _current_id;
    }


    /// @dev Get the token information
    /// @param id_ The id of the token
    /// @return The token information
    function getToken(uint id_) public view returns(TokenInformation memory){

        Provider memory provider_ = _providers[_tokens[id_]._provider];

        if(provider_._status > 1) // banned
          return TokenInformation(0, "", provider_);

        (bool has_meta_, bytes memory uri_) = _tokens[id_]._provider.staticcall(
          abi.encodeWithSignature(_providers[_tokens[id_]._provider]._function, _tokens[id_]._id)
        );

        // Convert the bytes to a string
        string memory uri_string_;
        if(uri_.length > 0)
          uri_string_ = string(abi.decode(uri_, (bytes)));


        return TokenInformation(
            _tokens[id_]._id,
            uri_string_,
            _providers[_tokens[id_]._provider]
        );

    }


    /// @dev get tokens for a provider
    /// @param provider_ The provider to get tokens for
    /// @param page_ The page to start from
    /// @param limit_ The limit of tokens to return
    /// @return The tokens for the provider
    function getTokens(address provider_, uint page_, uint limit_, bool ascending_) public view returns(TokenInformation[] memory) {

        require(_providers[provider_]._status <= 2, 'PROVIDER_BANNED');

        TokenInformation[] memory result_ = new TokenInformation[](limit_);

        uint index_ = 0;
        uint offset_ = page_ == 1 ? 0 : (page_ - 1) * limit_;
        uint start_ = ascending_ ? offset_ : _current_id;

        TokenInformation memory token_;

        if(ascending_){

            for(uint i = start_; i <= _current_id; i++){

              if(_tokens[i]._provider == provider_){
                if(index_ == limit_)
                  break;
                if(offset_ > 0){
                  offset_--;
                  continue;
                }
                if(token_._id != 0){
                  result_[index_] = token_;
                  index_++;
                }
              }

            }

          } else {

            for(uint i = start_; i > 0; i--){

              if(_tokens[i]._provider == provider_){
                if(index_ == limit_)
                  break;
                if(offset_ > 0){
                  offset_--;
                  continue;
                }
                token_ = getToken(i);
                if(token_._id != 0){
                  result_[index_] = token_;
                  index_++;
                }
              }

            }

          }


        return result_;

    }




}





contract TokenRegistryConfigurator is PollyConfigurator {

  function outputs() public pure override returns (string[] memory) {
    string[] memory output_ = new string[](1);
    // TODO: describe outputs
    return output_;
  }

  function run(Polly polly_, address for_, Polly.Param[] memory) public payable override returns (Polly.Param[] memory) {

    Polly.Param[] memory output_ = new Polly.Param[](outputs().length);

    // Configure tokenregistry contract
    address tr_ = polly_.cloneModule('TokenRegistry', 1);

    output_[0]._string = 'TokenRegistry';
    output_[0]._address = tr_;
    output_[0]._uint = 1;


    // Transfer ownership
    _transfer(tr_, for_);

    return output_;

  }

}
