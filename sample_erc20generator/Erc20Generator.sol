pragma solidity ^0.4.23;

import "./Erc20Token.sol";

contract Erc20Generator {
    
    mapping(address => address[]) public created;

    function Erc20Generator () {
    }
    
    function createErc20Token (string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) returns (address) {
        Erc20Token newToken = (new Erc20Token(_name, _symbol, _decimals, _totalSupply));
        created[msg.sender].push(address(newToken));
        newToken.transfer(msg.sender, _totalSupply);
        return address(newToken);
    }

}
