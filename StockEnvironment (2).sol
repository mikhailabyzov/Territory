pragma solidity ^0.4.16;

import './Ownable.sol';
import './SafeMath.sol';
import './Coin.sol';

contract StockEnvironment {
    using SafeMath for uint256;
    
    address master;
    
    uint256 public constant fee_percent = 5;
    
    uint256 public constant JCC_for_one_ETC = 20;
    
    address[] array_of_investors;
    
    Coin JCC = new Coin();
    Coin ETC = new Coin();
    Coin PIC = new Coin();
    
    function StockEnvironment(){
        master = msg.sender;
    }
    
    modifier onlyMaster(){
    require(msg.sender == master);
        _;
    }
    
    function MintSomeCurrency(address _wallet, string _alias, uint256 _amount) onlyMaster returns (bool success){
        if (sha256("ETC") == sha256(_alias)){
            success = ETC.mint(_wallet, _amount);
            return success;
        } 
        else if (sha256("JCC") == sha256(_alias)){
            success = JCC.mint(_wallet, _amount);
            return success;
        } 
        else if (sha256("PIC") == sha256(_alias)){
            success = PIC.mint(_wallet, _amount);
            return success;
        }
        else return false;
    }
    
    function PeekIntoWallet(address _wallet, string _alias) onlyMaster returns(bool, uint256){
        if (sha256("ETC") == sha256(_alias)){
            return (true, ETC.balanceOf(_wallet));
        } 
        else if (sha256("JCC") == sha256(_alias)){
            return (true, JCC.balanceOf(_wallet));
        } 
        else if (sha256("PIC") == sha256(_alias)){
            return (true, PIC.balanceOf(_wallet));
        }
        else return (false, 0);
    }
    
    function CheckMyBalances(string _alias) returns (bool, uint256){
        if (sha256("ETC") == sha256(_alias)){
            return (true, ETC.balanceOf(msg.sender));
        } 
        else if (sha256("JCC") == sha256(_alias)){
            return (true, JCC.balanceOf(msg.sender));
        } 
        else if (sha256("PIC") == sha256(_alias)){
            return (true, PIC.balanceOf(msg.sender));
        }
        else return (false, 0);
    }
    
    function AddNewInvestor(address _investor) onlyMaster returns (bool){
    for (uint i = 0; i < array_of_investors.length; i++){
            if (array_of_investors[i] == _investor) return false;
        }
    array_of_investors.length += 1;
    array_of_investors[array_of_investors.length - 1] = _investor;
    InvestorAdded(_investor);
    return true;
    }
    
    function CheckForAnInvestor(address _investor) returns (bool){
        for (uint i =0; i < array_of_investors.length; i++){
            if (array_of_investors[i] == _investor) return true;
        }
        return false;
    }
    
    function RemoveAnInvestor(address _investor) onlyMaster returns (bool){
        for (uint i = 0; i < array_of_investors.length; i++){
            if (array_of_investors[i] == _investor)
            {
                for(uint j = i; j < (array_of_investors.length - 1); j++){
                    array_of_investors[j] = array_of_investors[j+1];
                }
                delete array_of_investors[(array_of_investors.length - 1)];
                array_of_investors.length -= 1;
                return true;
            }
        }
        return false;
    }
    
    function PayBack (uint256 _sum) private returns (bool){
        uint256 fee_unit= _sum.div(PIC.totalSupply());
        for (uint i = 0; i < array_of_investors.length; i++){
            address _investor = array_of_investors[i];
            uint256 prize = ((PIC.balanceOf(_investor))*fee_unit);
            if(prize != 0)
            {   
            JCC.noApproveTransferFrom(master, _investor, prize);
            }
        }
        PayBackDone(_sum);
        return true;
    }
    
       function ExchangeInto(address _trader, uint256  _amount) returns (bool) {
        uint256 change = _amount * JCC_for_one_ETC;
        uint256 commission = (change / 100) * fee_percent;
        uint256 returnings = change - commission;
        bool success = true;
        success = ETC.noApproveTransferFrom(_trader, master, _amount);
        if(!success) return false;
        success = JCC.noApproveTransferFrom(master, _trader, returnings);
        PayBack(commission);
        if(!success) return false;
        ExchangeIntoMade(_trader, _amount);
        return success;
    }
      
        function ExchangeOutOf(address _trader, uint256  _amount) returns (bool) {
        uint256 commission = (_amount / 100) * fee_percent;
        uint256 change = (_amount - commission) / JCC_for_one_ETC;
        bool success = true;
        success = JCC.noApproveTransferFrom(_trader, master, _amount);
        if(!success) return false;
        success = ETC.noApproveTransferFrom(master, _trader, change);
        PayBack(commission);
        if(!success) return false;
        ExchangeOutOfMade(_trader, _amount);
        return success;
    }
    
        function TransferAmongTraders(address _from, address _to, uint256 _value) returns (bool){
        uint256 fee = (_value / 100)*fee_percent;
        bool success = JCC.noApproveTransferFrom(_from, _to, (_value - fee));
        PayBack(fee);
        return success;
    }
    
   function TransferMoneyBetweenAccounts(address _from, address _to, string _alias, uint256 _value) onlyMaster returns (bool success){
         if (sha256("ETC") == sha256(_alias)){
            success = ETC.noApproveTransferFrom(_from, _to, _value);
            return success;
        } 
        else if (sha256("JCC") == sha256(_alias)){
            success = JCC.noApproveTransferFrom(_from, _to, _value);
            return success;
        } 
        else if (sha256("PIC") == sha256(_alias)){
            success = PIC.noApproveTransferFrom(_from, _to, _value);
            return success;
        }
        else return false;
   }
    
    
        function KillStock() onlyMaster {
            ContractSuicided(master);
            selfdestruct(master);
    }
    
    
    
    event InvestorAdded(address _investor);
    event PayBackDone(uint256 _sum);
    event ExchangeIntoMade(address _trader, uint256 _amount);
    event ExchangeOutOfMade(address _trader, uint256 _amount);
    event InvestorDeleted(address _investor);
    event PICSwapped(address _from, address _to, uint256 _value);
    event TransferPerformed(address _from, address _to, uint256 _value);
    event ContractSuicided(address _master);
}