// SPDX-License-Identifier: MIT  
//1.0
pragma solidity >=0.7.0 <0.9.0;

interface Icya {     
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  }

interface Icyacoop{
  function levelcheck(address user)external view returns(uint8);
  function expup(address user,uint pay) external returns(bool);
}
    contract cyapension{  
      Icya cya;
      Icyacoop cyacoop;
      address cyatax;
      uint256 public tax;
      uint256 public amends;
      address admin;

        
  
    constructor(address _cya,address _cyacoop) public {
      cya=Icya(_cya);
      cyacoop=Icyacoop(_cyacoop);
      cyatax = _cyacoop; // 세금을 보내기 위한 메소드
      admin = msg.sender;
      }
   
    struct my{
    uint256 depo;
    uint256 allocya; 
    address owner;
    address spender;
    address heritor;
    uint32 key;  
    }


function creat(uint256 pay,address _spender,address _heritor)public {
        require (pay <= g5(),"over");
        require (cyacoop.levelcheck(msg.sender) >= 7,"level little");
        require(cya.balanceOf(msg.sender) >= pay,"no cya"); 
        cya.approve(msg.sender, pay);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);  
        myinfo[msg.sender].depo = pay*8;
        amends += pay*8;
        myinfo[msg.sender].owner = msg.sender;
        myinfo[msg.sender].spender = _spender;
        myinfo[msg.sender].heritor = _heritor;
        myinfo[msg.sender].key = 1040;
        myinfo[msg.sender].allocya = block.timestamp;
        tax += pay * 10/100;
}

function withdraw(address user )public returns(bool){
    require(myinfo[user].key >= 1,"no key"); 
    require(myinfo[user].allocya + 7 days < block.timestamp,"no time");
    require(myinfo[user].spender == msg.sender,"no spender");
    uint256 pay = myinfo[user].depo/myinfo[user].key;
    require(g1() >= pay,"no cya"); 
    myinfo[msg.sender].allocya = block.timestamp;
    myinfo[msg.sender].depo -= pay;
    myinfo[msg.sender].key -= 1;
    cya.transfer(msg.sender,pay);
    amends -= pay;
    if(tax >= 1e19){
    cya.transfer(cyatax,tax);
    tax = 0; 
    return true;
 }
}
function spenderup(address newspender)public returns(bool){    
    require(myinfo[msg.sender].owner == msg.sender ,"no owner");
    myinfo[msg.sender].spender = newspender; 
    return true;
}

function heritorup(address newheritor)public returns(bool){    
    require(myinfo[msg.sender].owner == msg.sender ,"no owner");
    myinfo[msg.sender].heritor = newheritor; 
    return true;
}
function succession(address user)public returns(bool){    
    require(myinfo[user].heritor == msg.sender,"no heritor");
    require(myinfo[user].allocya + 30 days < block.timestamp,"not time" ); 
    myinfo[msg.sender].owner = msg.sender; 
    return true;
}
function depoup(uint256 pay)public returns(bool){    
    require(myinfo[msg.sender].owner == msg.sender ,"no owner");
    require(myinfo[msg.sender].key >= 1,"no key" );
      cya.approve(msg.sender, pay);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);  
    myinfo[msg.sender].depo += pay*8;
    myinfo[msg.sender].key = 1040;
    myinfo[msg.sender].allocya = block.timestamp; 
    return true;
}

   
function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

function g2() public view returns(uint256 depo,uint256 allocya,address owner,address spender,address heritor,uint32 key){  
  return (myinfo[msg.sender].depo,
          myinfo[msg.sender].allocya,
          myinfo[msg.sender].owner,
          myinfo[msg.sender].spender,
          myinfo[msg.sender].heritor,
          myinfo[msg.sender].key);
  }  

  function g3() public view virtual returns(uint256){  
  return cya.balanceOf(msg.sender);
  }

  function g4(address user) public view returns(uint256 depo,uint256 allocya,address owner,address spender,address heritor,
  uint32 key){  
  return ( myinfo[user].depo,
           myinfo[user].allocya,
           myinfo[user].owner,
           myinfo[user].spender,
           myinfo[msg.sender].heritor,
           myinfo[user].key);
  }  
  function g5() public view virtual returns(uint256){  
  return g1()-amends;
  }
}
  
