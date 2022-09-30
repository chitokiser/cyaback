// SPDX-License-Identifier: MIT  
// ver1.0
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

    contract cyatrain {
      Icyacoop cyacoop;
      Icya cya;
      address custallow;
      address admin;
      uint256 public tax;
      uint256 public fee;
      uint256 public tp; //누적 승객 총수
      uint256[32]train; 
      mapping(address => my)public myinfo;
      
    constructor(address _cyacoop,address _cya,address _custallow) public { 
      cyacoop = Icyacoop(_cyacoop);
      cya =Icya(_cya);
      admin = msg.sender;
      fee = 1e16;  //승차요금
    }

   
    
    struct my { 
    uint256 mynum; // 몇 번째 탔는지? 나의 승객넘버
    uint mytn;  //내가탄  기차 호수
    }

function feeup(uint256 num) public { 
  require(admin == msg.sender,"no admin");
  fee = num;
}
function geton() public { 
  uint num = ranmod(); //0~32
    require(myinfo[msg.sender].mynum == 0,"already passenger"); 
    require(g2(msg.sender) >= fee,"no cya"); 
        cya.approve(msg.sender,fee);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= fee, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), fee);  
      cyacoop.expup(msg.sender,fee);
      train[num] += 1;
 
    
   }


  function ranmod( ) internal returns(uint){
   return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender))) % 32+1; //test10
 }

  function getoff( )public returns(bool) {   
 my storage tmy = myinfo[msg.sender];  
 require(tmy.mynum >= 1 ,"no passenger");
 require(tp-tmy.mytn >=4,"littl passenger");
  uint256 rate = (tp - tmy.mytn) * train[tmy.mytn];
  uint256 pay = fee*rate/10;
 require(g1() >=pay,"no cya");
   train[tmy.mytn] -= 1;
   tmy.mynum = 0;

  }

  function taxtransfer( )public returns(bool) {   //myport에서 가져온 portid
   require(tax>=1e18,"tax litttle");
   uint256 taxt=tax;
   tax = 0;
   cya.transfer(msg.sender,tax);
   return true;
  }

 
 function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }
   
 function g2(address user) public view virtual returns(uint256){  
  return cya.balanceOf(user);
  }
 function g3() public view returns(uint) {  
  uint256 rate = tp - (myinfo[msg.sender].mytn * train[myinfo[msg.sender].mytn]);
  return fee* rate/10;
   }
  
  function g4() public view returns(uint,uint) {  
  return (myinfo[msg.sender].mynum,
          myinfo[msg.sender].mytn);
   }
 function getpassenger(uint num) public view returns(uint) {  

  return train[num];
   }

  function deposit()external payable{}
}
    

