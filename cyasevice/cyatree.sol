// SPDX-License-Identifier: MIT  
// ver1.0
pragma solidity >=0.7.0 <0.9.0;


interface Icya {     
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 happy) external returns (bool);
  function approve(address spender, uint256 happy) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 happy) external returns (bool);
  }

interface Icyacoop{
  function levelcheck(address user)external view returns(uint8);
  function expup(address user,uint pay) external returns(bool);
}

    contract cyatree {
      Icyacoop cyacoop;
      Icya cya;
      address custallow; // for tax
      address admin;
      uint256 public sum;  
      uint256 public happy; 
      uint256 public fee;
      uint256 public tax;
      uint256 public jt; //jackpot time
      address public lastman;  //잭팟 수혜자
      address[]public mentolist;
      mapping (address => my)public myinfo;
      
   
     constructor(address _cyacoop,address _cya,address _custallow) public { 
    
      happy = 1e16 ; //수당
      fee = 15e16;  //150불
      cyacoop =Icyacoop(_cyacoop);
      custallow = _custallow;
      cya = Icya(_cya);
      jt = block.timestamp;
      admin =msg.sender;
      myinfo[msg.sender].dep = 2;
      myinfo[msg.sender].mynum = 1;
      myinfo[msg.sender].tiket = 12;
    
      }

    struct my {
    uint256 depo; 
    uint256 dep;
    uint256 mynum;
    uint8 wc;  //withdraw limit
    uint256 tiket;
    }
function addautomento( ) public { 
        require(myinfo[msg.sender].dep >= 1,"no member"); 
        require (cya.balanceOf(msg.sender)>=fee*2,"no cya");
        cya.approve(msg.sender,fee*2);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= fee*2, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this),fee*2);
        mentolist.push(msg.sender);   
    }
function automemberjoin( )public {   
    require(myinfo[msg.sender].dep == 0,"already member"); 
    require (cya.balanceOf(msg.sender)>=fee,"no cya");
        cya.approve(msg.sender,fee);
        uint256 allowance = cya.allowance(msg.sender, address(this));
    require(allowance >= fee, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), fee);
    uint num = random();
    address mento = getmento(num);
      myinfo[msg.sender].dep = 2;
      myinfo[msg.sender].tiket += 15;
      myinfo[mento].tiket += myinfo[mento].dep;
      cyacoop.expup(mento,fee);
      sum += 1;
      tax += fee*10/100;
      lastman = msg.sender;
      jt = block.timestamp;
}

function memberjoin(address _mento )public {   //수동가입이 있어야 인출티겟을 증가 시킬 수 있음
    require(myinfo[msg.sender].dep == 0,"already member"); 
    require(myinfo[_mento].dep >=2,"no mento"); 
    require (cya.balanceOf(msg.sender)>=fee,"no cya");
        cya.approve(msg.sender,fee);
        uint256 allowance = cya.allowance(msg.sender, address(this));
    require(allowance >= fee, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), fee);
      myinfo[msg.sender].dep = 2;
      myinfo[msg.sender].mynum = sum;

      myinfo[_mento].tiket += myinfo[_mento].dep;
      cyacoop.expup(_mento,fee);
      sum += 1;
      tax += fee*10/100;
      lastman = msg.sender;
      jt = block.timestamp;  
    }
function check() public { 
    my storage tmy = myinfo[msg.sender]; 
    require(tmy.dep >=1 ,"no member");
    require(sum - tmy.mynum >= tmy.dep,"little member");
    require(tmy.tiket >=tmy.dep,"little tiket");
    require(tmy.wc < 15,"over withdraw");  //15회 인출 가능
    uint256 pay = happy*900/(950+tmy.dep-getlevel(msg.sender));
    tmy.depo += pay*tmy.dep;
    tmy.mynum = (tmy.mynum+2)*2;
    tmy.tiket -= tmy.dep; 
    tmy.dep = tmy.dep*2;
    tmy.wc += 1;
}
   
  function withdraw( )public {   
   uint256 pay = myinfo[msg.sender].depo * 90/100;
   require(pay > 0,"no depo");
   require(g1() >= pay,"no cya");
   myinfo[msg.sender].depo = 0; 
   cya.transfer(msg.sender,pay);
    if(tax >= 1e18){ 
   cya.transfer(custallow,tax);
   tax =0; 
   }
  }
  


  function custallowtup(address _custallow) public {
   require(admin == msg.sender,"no admin");
      custallow = _custallow;
   }    

    
  function feeup(uint _fee) public {
   require(admin == msg.sender,"no admin");
      fee = _fee;  
   }  

 function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }
  
 function g2() public view returns( uint256 depo,uint256 dep,uint256 mynum,uint8 wc,uint256 tiket){  
   my storage tmy=myinfo[msg.sender];
  return ( tmy.depo,
           tmy.dep,
           tmy.mynum,
           tmy.wc,
           tmy.tiket);
  }    
  function random() public view returns(uint){  //ver 1.1
  return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender))) % mentolength(); 
 }    
  function mentolength() public view returns(uint) { //geteps 호출용
  return mentolist.length;
  } 
 function getmento(uint num) public view returns(address) {
  return mentolist[num];
    }
 function getsum( ) public view returns(uint) {
  return sum;
    }
 function getlevel(address user) public view returns(uint8) {
  return cyacoop.levelcheck(user);
    }
    function thistimepoint( ) public view returns(uint) { 
      my storage tmy = myinfo[msg.sender]; 
  return happy*900/(950+tmy.dep)*tmy.dep;
    }
  function deposit()external payable{
  }

}
  
