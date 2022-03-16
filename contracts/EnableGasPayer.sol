pragma solidity ^0.7.2;

/**
 * @title EnableGasPayer
 * @author Bui Duc Huy<duchuy.124dk@gmail.com>
 * @dev Implementation of the contract enable pay gas.
 */
contract EnableGasPayer {
  event RegisterContract(address indexed contractAddress, address indexed payer);
  event EnablePayGas(address indexed contractAddress, bytes4[] methods);
  event DisablePayGas(address indexed contractAddress, bytes4[] methods);
  event Withdraw(address indexed contractAddress, address payer);

  mapping(address => mapping(bytes4 => bool)) public _enableMethod;
  mapping(address => bool) public _enableContracts;
  mapping(address => address) public _payers;
  uint256 public LOCK_VALUE;

  function setLockValue(uint256 _lockValue) public {
    LOCK_VALUE = _lockValue;
  }

  function register(address _contract) payable public {
    require(_enableContracts[_contract] == false, "Coin98 EnableGasPayer: Contract Is Enable");
    require(msg.value == LOCK_VALUE, "Coin98 EnableGasPayer: Exceed Value");
    _enableContracts[_contract] = true;
    _payers[_contract] = msg.sender;

    emit RegisterContract(_contract, msg.sender);
  }

  function _setEnable(address _contract, bytes4[] memory _methods, bool isEnable) private {
    for (uint i = 0; i < _methods.length; i++) {
      _enableMethod[_contract][_methods[i]] = isEnable;
    }
  }

  function enable(address _contract, bytes4[] memory _methods) payable public {
    require(msg.sender == _payers[_contract], "Coin98 EnableGasPayer: Sender is not payer");
    _setEnable(_contract, _methods, true);

    emit EnablePayGas(_contract, _methods);
  }

  function disable(address _contract, bytes4[] memory _methods) payable public {
    require(msg.sender == _payers[_contract], "Coin98 EnableGasPayer: Sender is not payer");
    _setEnable(_contract, _methods, false);

    emit DisablePayGas(_contract, _methods);
  }

  function isEnableContract(address _contract, bytes4 _method) view public returns(bool) {
    return _enableContracts[_contract] && _enableMethod[_contract][_method];
  }

  function withdraw(address _contract) payable public {
    require(_payers[_contract] == msg.sender, "Coin98 EnablePayGas: Not payer");
    require(_enableContracts[_contract], "Coin98 EnablePayGas: Not Enable Contract");

    _enableContracts[_contract] = false;

    (bool sent, bytes memory data) = msg.sender.call{value: LOCK_VALUE}("");

    require(sent, "Coin98 EnablePayGas: Failed to send C98");

    emit Withdraw(_contract, msg.sender);
  }
}
