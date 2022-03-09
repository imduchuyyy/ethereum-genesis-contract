pragma solidity ^0.8.11;

/**
 * @title EnablePayGas
 * @author Bui Duc Huy<duchuy.124dk@gmail.com>
 * @dev Implementation of the contract enable pay gas.
 */
contract EnableGasPayer {
  event EnablePayGas(address indexed contractAddress, bytes method, address indexed payer);
  event Withdraw(address indexed contractAddress, address payer);

  mapping(address => mapping(bytes => bool)) _enableMethod;
  mapping(address => bool) _enableContracts;
  mapping(address => address) _payers;

  uint256 _lockValue;

  constructor(uint256 _lockValue) public {
    _lockValue = _lockValue;
  }

  function enable(address _contract, bytes memory _method) payable public {
    require(msg.value < _lockValue, "Coin98 EnablePayGas: Exceed Value");
    _enableContracts[_contract] = true;
    _enableMethod[_contract][_method] = true;
    _payers[_contract] = msg.sender;

    emit EnablePayGas(_contract, _method, msg.sender);
  }

  function isEnable(address _contract, bytes memory _method) view public returns(bool) {
    return _enableContracts[_contract][_method];
  }

  function withdraw(address _contract) payable public {
    require(_payer[_contract] == msg.sender, "Coin98 EnablePayGas: Not payer");
    require(_enableContracts[_contract] == true, "Coin98 EnablePayGas: Not Enable Contract");

    _enableContracts[_contract] = false;

    (bool sent, bytes memory data) = msg.sender.call{value: _lockValue}("");

    require(sent, "Coin98 EnablePayGas: Failed to send C98")

    emit Withdraw(_contract, msg.sender);
  }
}
