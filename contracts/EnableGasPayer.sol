pragma solidity ^0.7.0;
import "./utils/Ownable.sol";
import "./utils/Address.sol";
import "./interfaces/IEnableGasPayer.sol";

/**
 * @title EnableGasPayer
 * @author Bui Duc Huy<duchuy.124dk@gmail.com>
 * @dev Implementation of the contract enable pay gas.
 */
contract EnableGasPayer is IEnableGasPayer, Ownable {
    mapping(address => mapping(bytes4 => bool)) private _enableMethod;
    mapping(address => bool) private _enableContracts;
    mapping(address => address) private _payers;
    uint256 public LOCK_VALUE;
    bool _isInitial;

    modifier isNotInit() {
        require(!_isInitial, "Coin98 EnableGasPayer: Contract has been init");
        _;
    }

    function _getAddressCreate(address _creator, uint _nonce) internal pure returns(address) {
        bytes memory data;
        if (_nonce == 0x00) {
            data = abi.encodePacked(byte(0xd6), byte(0x94), _creator, byte(0x80));
        } else if (_nonce <= 0x7f) {
            data = abi.encodePacked(byte(0xd6), byte(0x94), _creator, uint8(_nonce));
        } else if (_nonce <= 0xff) {
            data = abi.encodePacked(byte(0xd7), byte(0x94), _creator, byte(0x81), uint8(_nonce));
        } else if (_nonce <= 0xffff) {
            data = abi.encodePacked(byte(0xd8), byte(0x94), _creator, byte(0x82), uint16(_nonce));
        } else if (_nonce <= 0xffffff) {
            data = abi.encodePacked(byte(0xd9), byte(0x94), _creator, byte(0x83), uint24(_nonce));
        } else {
            data = abi.encodePacked(byte(0xda), byte(0x94), _creator, byte(0x84), uint32(_nonce));
        }
        return address(uint256(keccak256(data)));
    }

    function _getAddressCreate2(address _creator, bytes32 _codeHash, uint256 _salt) internal pure returns(address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), _creator, _salt, _codeHash)))));
    }

    function _setEnable(address _contract, bytes4[] memory _methods, bool isEnable) private {
        for (uint i = 0; i < _methods.length; i++) {
            _enableMethod[_contract][_methods[i]] = isEnable;
        }
    }

    function init(uint256 _lockValue) onlyOwner public {
        _isInitial = true;
        LOCK_VALUE = _lockValue;
    }

    function register(address _contract, bytes32 _codeHash, uint256 _nonce, bool _isCreate2) payable public {
        address contractAddress;
        if (_isCreate2) {
            contractAddress = _getAddressCreate2(msg.sender, _codeHash, _nonce);
        } else {
            contractAddress = _getAddressCreate(msg.sender, _nonce);
        }

        require(_contract == contractAddress, "Coin98 EnableGasPayer: Contract address invalid");
        require(_enableContracts[_contract] == false, "Coin98 EnableGasPayer: Contract Is Enable");
        require(msg.value == LOCK_VALUE, "Coin98 EnableGasPayer: Exceed Value");
        _enableContracts[_contract] = true;
        _payers[_contract] = msg.sender;

        emit RegisterContract(_contract, msg.sender);
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
        
        Address.sendValue(msg.sender, LOCK_VALUE);
        emit Withdraw(_contract, msg.sender);
    }
}
