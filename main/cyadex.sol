// SPDX-License-Identifier: MIT
// ver1.2
pragma solidity >=0.7.0 <0.9.0;
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
   }
contract ERC20Basic is IERC20 {
    string public constant name = "CyaToken";
    string public constant symbol = "CYA";
    uint8 public constant decimals = 18;
    address admin;
    address cyadex;
    bool dexup;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
constructor() {
    admin=msg.sender;  }
   function cyadexup(address _cyadex)public{   
    require(admin==msg.sender,"no admin");
    require(dexup == false,"only one up");  
    cyadex = _cyadex;
    dexup = true;}
   
   function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner]; }
   function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true; }
   function approve(address owner, uint256 numTokens) public override returns (bool) {
        allowed[owner][msg.sender] = numTokens;
        emit Approval(owner, msg.sender, numTokens);
        return true; }
    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }
    function mint() public {
        require(admin==msg.sender);
        balances[cyadex] += 1000000*1e18;  }
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]+numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;}
}

contract Cyadex {
    uint256 public price;
    address alliance;
    address public cyacoop;
    address admin;
    mapping(address => uint256)public shoper;
    mapping(address => uint8)public step;
    mapping(address => uint8)public confirm;
    IERC20 cya; 

    constructor(address _cya) {
        cya = IERC20(_cya);
        price = 1000;
        admin = msg.sender; }
    function transfercoop(uint256 num)public{
        require( admin == msg.sender);
        cya.transfer(cyacoop,num*1e18);}
    function confirmup(address shopowner,uint8 num)public{ 
        require(step[msg.sender] >= 1 ,"no step");
        confirm[shopowner] = num;
    }
    function allianceup(address _alli)public{
        require( admin == msg.sender);
        alliance = _alli;}
    function shoperup(address user,uint256 pay)public returns(bool) { 
        require(alliance == msg.sender,"no alliance");
        shoper[user] += pay;
        return true; }
    function cyacoopup(address _cyacoop) public {  
        require (admin == msg.sender,"no admin");
        cyacoop = _cyacoop; }
    function buy() payable public {
        uint256 pay = msg.value*price/1000;
        uint256 dexbal = cya.balanceOf(address(this));
        require(pay <= dexbal, "Not enough tokens");
        require(msg.value>=1e15,"Not enough ether"); 
        cya.transfer(msg.sender,pay); }

    function sell(uint256 num) public {  
        uint256 pay=num/price*980;
        require(shoper[msg.sender] >= num,"no shoper");
        require(balance() >= pay,"no ether");
        require(confirm[msg.sender] >= 1,"no confirm");
        shoper[msg.sender] -= num;
        cya.approve(msg.sender,num);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= num, "Check allowance");
        cya.transferFrom(msg.sender, address(this), num);
        payable(msg.sender).transfer(pay); }

    function priceup(uint256 num)public {  
        require(step[msg.sender] >= 1,"no step"); 
        price = num;
        step[msg.sender] -= 1;  }
    function stepup(uint8 num,address _step)public {  
        require(admin == msg.sender,"no amdin");
        step[_step] = num; }
    
    function deposit()external payable{
    }
    function getprice()public view returns(uint256){  
        return price;
   }
    function balance()public view returns(uint256){   
        return address(this).balance;
   }
    
    function cyabalances() public view returns(uint256) {
        return cya.balanceOf(address(this));
    }
    function mycyabalances() public view returns(uint256) {
        return cya.balanceOf(msg.sender);
    }
    function getshoper() public view returns(uint256) {
        return shoper[msg.sender];
    }
}

