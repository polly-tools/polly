// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@polly-tools/core/contracts/PollyModule.sol";


interface ERC20 {
  function balanceOf(address account) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);
}

interface ERC721 {
  function balanceOf(address account) external view returns (uint);
  function ownerOf(uint tokenId) external view returns (address);
}

interface ERC1155 {
  function balanceOf(address account, uint id) external view returns (uint);
  function balanceOfBatch(address[] calldata accounts, uint[] calldata ids) external view returns (uint[] memory);
}

contract TokenGates is PMReadOnly {

  enum Types { ERC721, ERC1155, ERC20 }

  struct Rule {
    address _address;
    uint _min;
    uint _max;
    uint[] _ids;
  }

  struct Gate {
    Rule[] _rules;
    uint _id;
    address _owner;
  }

  mapping(uint => Gate) private _gates;
  uint private _gate_count;

  string public constant override PMNAME = "TokenGates";
  uint public constant override PMVERSION = 1;


  event GateCreated(uint gate_id, address indexed owner);
  event GateUpdated(uint gate_id, address indexed owner);

  modifier onlyGateOwner(uint gate_id) {
    require(_gates[gate_id]._owner == msg.sender, "TokenGates: Only gate owner can call this function");
    _;
  }


  constructor(address polly) PMReadOnly() {

  }

  function createGate(Rule[] memory rules_) external returns (uint gate_id_) {
    gate_id_ = _gate_count++;
    _gates[gate_id_] = Gate(rules_, gate_id_, msg.sender);
    emit GateCreated(gate_id_, msg.sender);
    return gate_id_;
  }


  function updateGate(uint gate_id_, Rule[] memory rules_) external onlyGateOwner(gate_id_) {
    _gates[gate_id_]._rules = rules_;
    emit GateUpdated(gate_id_, msg.sender);
  }


  function updateGateRules(uint gate_id_, uint rule_index_, Rule memory rule_) external onlyGateOwner(gate_id_) {
    _gates[gate_id_]._rules[rule_index_] = rule_;
    emit GateUpdated(gate_id_, msg.sender);
  }


  function transferGate(uint gate_id_, address new_owner_) external onlyGateOwner(gate_id_) {
    _gates[gate_id_]._owner = new_owner_;
  }

  function getGate(uint gate_id) public view returns(Gate memory) {
    return _gates[gate_id];
  }

  function getGateCount() public view returns(uint) {
    return _gate_count;
  }


  function canPass(address check_, uint gate_id_) external view returns (bool can_pass_) {
    Gate memory gate = _gates[gate_id_];
    for (uint i = 0; i < gate._rules.length; i++) {
      Rule memory rule_ = gate._rules[i];
      if(!_checkRule(rule_))
        return false;
    }
    return true;
  }


  function _checkRule(Rule rule_, address check_) private {


    if(min > 0 || max > 0) {

      uint balance;

      if(rule_._type == Types.ERC721) {
        balance = ERC721(rule_._address).balanceOf(check_);
      } else if(rule_._type == Types.ERC20) {
        balance = ERC20(rule_._address).balanceOf(check_);
      }

      if(rule._min > 1 && balance < rule_._min)
        return false;

      if(rule._max > 0 && balance > rule_._max)
        return false;

    }

    if(rule._ids.length > 0) {

      if(rule._type == Types.ERC1155){
        uint[] memory balances_ = ERC1155(rule_._address).balanceOfBatch(check_, rule_._ids);
        for (uint i = 0; i < balances_.length; i++) {
          if(balances_[i] == 0)
            return false;
        }
      } else if(rule._type == Types.ERC721) {
        for (uint i = 0; i < rule_._ids.length; i++) {
          if(ERC721(rule_._address).ownerOf(rule_._ids[i]) != check_)
            return false;
        }
      }

    }

    return true;

  }

}
