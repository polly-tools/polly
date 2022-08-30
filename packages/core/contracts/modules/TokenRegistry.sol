//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import '../Polly.sol';
import '../PollyConfigurator.sol';

/// @title Token Registry module
/// @author Polly
/// @dev The Token Registry module allows token providers to register tokens

contract TokenRegistry is PollyModule {

    /// STRUCTS

    struct Provider {
        string _identifier; // A string identifier for the provider
        address _address; // The address of the provider
        string _function; // The function signature of the provider
        string _token_url; // A direct url to a token - use {id} to insert the token id
        string _url; // A main url of the provider
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
    uint private _count;
    mapping(uint => Token) private _tokens;
    mapping(address => Provider) private _providers;
    mapping(address => mapping(address => bool)) private _provider_controllers;

    /// EVENTS
    event TokenRegistered(
        address indexed _address,
        uint _id
    );


    /// MODIFIERS

    /// @dev modifier to allow only sender with role MANAGER to call this function
    modifier onlyManager {
        require(hasRole(MANAGER, msg.sender), 'ONLY_MANAGER');
        _;
    }

    modifier onlyProvider(){
      require(_providers[msg.sender]._address != address(0), 'ONLY_PROVIDER');
      _;
    }


    /// POLLY

    function moduleInfo() public pure returns (IPollyModule.Info memory) {
        return IPollyModule.Info('TokenRegistry', true);
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
    /// @param internal_id_ The id of the token
    function _registerToken(address provider_, uint internal_id_) private returns(uint) {
        _count++;
        _tokens[_count] = Token(provider_, internal_id_);
        emit TokenRegistered(provider_, internal_id_);
        return _count;
    }


    /// @dev Register a new token
    /// @param internal_id_ The id of the token
    /// @return id the id of the newly registered token
    function registerToken(uint internal_id_) public returns(uint) {

      if(_providers[msg.sender]._status != 0)
        return 0; // provider is disabled or banned

      require(msg.sender == _providers[msg.sender]._address, 'ONLY_PROVIDER');

      return _registerToken(msg.sender, internal_id_);

    }


    /// @dev batch register tokens for a provider
    /// @param provider_ The provider of the tokens
    /// @param ids_ The ids of the tokens
    function batchRegisterTokens(address provider_, uint[] memory ids_) public returns(uint[] memory) {

      if(_providers[msg.sender]._status != 0)
        return new uint[](0); // provider is disabled or banned

      require(_provider_controllers[msg.sender][provider_], 'ONLY_PROVIDER_CONTROLLER');
      uint[] memory result_ = new uint[](ids_.length);
      for (uint i = 0; i < ids_.length; i++) {
       result_[i] = _registerToken(provider_, ids_[i]);
      }

      return result_;

    }


    /// @dev Get the total token count
    /// @return The total token count
    function getTokenCount() public view returns (uint) {
        return _count;
    }


    /// @dev Get the token information
    /// @param id_ The id of the token
    /// @return The token information
    function getToken(uint id_) public view returns(TokenInformation memory){

        Provider memory provider_ = _providers[_tokens[id_]._provider];

        require(provider_._status <= 2, 'PROVIDER_BANNED');

        (bool has_meta_, bytes memory uri_) = _tokens[id_]._provider.staticcall(
          abi.encodeWithSignature(_providers[_tokens[id_]._provider]._function, _tokens[id_]._id)
        );

        return TokenInformation(
            _tokens[id_]._id,
            has_meta_ ? string(uri_) : "",
            _providers[_tokens[id_]._provider]
        );

    }


}
