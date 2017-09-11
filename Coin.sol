pragma solidity ^0.4.16;

import './Ownable.sol';
import './SafeMath.sol';


contract Coin is Ownable {

    using SafeMath for uint256;
	
    uint8 public constant decimals = 18;
	
    mapping (address => uint256) balances;
	
    uint256 public totalSupply = 0;
	
    bool public mintingFinished = false;
    
    modifier canMint() {
    require(!mintingFinished);
    _;
  }
  
    mapping (address => mapping(address => uint256)) allowed;
	
	 function Coin(){}
    
    function totalSupply()external constant returns (uint256 total_Supply) {
        return totalSupply;
    }
    
    function balanceOf(address _owner)external constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) external returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
  
    function allowance(address _owner, address _spender) external constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  
    function approve(address _spender, uint256 _value)external returns (bool) {
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  } 
  
    function mint(address _to, uint256 _amount) onlyOwner canMint external returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

    function finishMinting() onlyOwner external returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
    function noApproveTransferFrom(address _from, address _to, uint256 _value) onlyOwner external returns (bool) {
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  } 
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
}