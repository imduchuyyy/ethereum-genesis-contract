pragma solidity ^0.7.0;

interface IEnableGasPayer {
    event RegisterContract(address indexed contractAddress, address indexed payer);
    event EnablePayGas(address indexed contractAddress, bytes4[] methods);
    event DisablePayGas(address indexed contractAddress, bytes4[] methods);
    event Withdraw(address indexed contractAddress, address payer);
}
