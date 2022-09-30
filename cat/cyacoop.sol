// SPDX-License-Identifier: MIT  
//ver1.2
pragma solidity >=0.7.0 <0.9.0;

interface Icya {     
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  }


interface Icat{
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function getdepot(address user)external view returns(uint256);
  }

  
    contract Cyacoop {
      Icya cya;
      Icat cat;
      uint256 public sum; 
      uint256 public price; 
      uint256 public allow; 
      uint256[]public chart; 
      address public admin;
      address[]public mentolist;

          
    constructor(address _cya,address _cyadex,address _cat,uint256 _allow,uint256 _price) public {
      price=_price*1e12;
      cya=Icya(_cya);
      cat=Icat(_cat);
      myinfo[msg.sender].level=20;    
      allow=_allow*1e12;
      admin=msg.sender;
      mentolist.push(msg.sender);
      }
    
    struct my {
    uint256 allocya; 
    uint256 exp; 
    uint8 level;
    uint256 booster;
    }
  
    function addmento( ) public { 
        require(myinfo[msg.sender].level >= 1,"low level"); 
        require (cya.balanceOf(msg.sender)>=5e17,"no cya");
        cya.approve(msg.sender,5e17);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= 5e17, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), 5e17);
        mentolist.push(msg.sender);   
    }

function memberjoin(uint256 _num) public {  
    require(myinfo[msg.sender].level == 0,"already member"); 
    require (cya.balanceOf(msg.sender)>=5e16,"no cya");
        cya.approve(msg.sender,5e16);
        uint256 allowance = cya.allowance(msg.sender, address(this));
    require(allowance >= 5e16, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), 5e16);
      myinfo[msg.sender].level = 1;
      mymento[msg.sender] = mentolist[_num];
      sum += 1;
   }
function automemberjoin( )public {   //v1.1
    require(myinfo[msg.sender].level == 0,"already member"); 
    require (cya.balanceOf(msg.sender)>=5e16,"no cya");
        cya.approve(msg.sender,5e16);
        uint256 allowance = cya.allowance(msg.sender, address(this));
    require(allowance >= 5e16, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), 5e16);
    uint num = random();
    myinfo[msg.sender].level = 1;
    mymento[msg.sender] = mentolist[num];
    sum += 1;
    }

function buycat(uint _num) public returns(bool) {  
   uint pay = _num * price;
    require(g6() >= _num,"sold out");  
    require(_num >=1,"no decimals");
    require(cya.balanceOf(msg.sender) >= pay,"no cya"); 
    require(myinfo[msg.sender].level >= 1,"no meber"); 
      cya.approve(msg.sender, pay);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);  
       cat.transfer(msg.sender,_num);
      myinfo[msg.sender].allocya = block.timestamp;
      priceup();
      myinfo[mymento[msg.sender]].exp += pay/1e12;
      myinfo[msg.sender].exp += pay/1e13;
      return true;     
}

function sellcat(uint num)public returns(bool){      //한번에 파는게아닌 일부만 팔 수 있음 
    require(g7(msg.sender) >= num,"no cct");
    require(myinfo[msg.sender].level >=1,"no member"); 
    require(cat.getdepot(msg.sender) + 365 days  <  block.timestamp,"not time");   
  uint256  pay = num*price;  
    cya.transfer(msg.sender,pay);
    cat.approve(msg.sender, num);
        uint256 allowance = cat.allowance(msg.sender, address(this));
        require(allowance >= num, "Check the token allowance");
        cat.transferFrom(msg.sender, address(this), num); 
    priceup();
    return true;
}

function withdraw( )public returns(bool){   

    require(g7(msg.sender)>=1,"no cat"); 
    require(myinfo[msg.sender].allocya + 7 days   <  block.timestamp,"not time"); //주1회
    uint256 pay = g7(msg.sender)*allow*myinfo[msg.sender].level/1000;  
     myinfo[msg.sender].allocya=block.timestamp;
     cya.transfer(msg.sender,pay);
    return true;
}
function adminex(address newadmin)public{
    require(admin == msg.sender);
    admin = newadmin;
}

function voteup(address _vote)public {
 require(admin == msg.sender);
 vote = _vote;
}
function votewithdraw()public { //의장 특별인출권
  require(chairman == msg.sender,"no chairman");
  require(ct + 30 days <=  block.timestamp,"not time");  //1개월
  ct = block.timestamp;
  uint256 pay = cya.balanceOf(address(this))*10/100;
  cya.transfer(vote,pay);
}

function priceup( )public {
    uint sold = 1e9-g6();
    allow=g1()/sold; 
    price=allow*2;
    chart.push(price);   
}


function levelup( )public returns(bool){
       my storage tmy=myinfo[msg.sender];
      require(tmy.level >= 1);
      require(tmy.exp>=2**tmy.level*10000,"no exp");
      tmy.exp -= 2**tmy.level*10000;
      tmy.level += 1;
      return true;
  }

function familyup(address _fa,uint8 num)public{
      require(admin == msg.sender);
      fs[_fa] = num;
}

function expup(address user,uint pay)public returns(bool){
      require(fs[msg.sender] >= 5,"no family");
      myinfo[user].exp += (myinfo[user].booster +pay) /1e13;
      myinfo[user].booster -= myinfo[user].booster/100; 
      emit boostvalue(myinfo[user].booster,pay);
      return true;
}
   
function boosting()public returns(bool){
      require(cya.balanceOf(msg.sender) >= 1e17,"no cya"); //$100
      require(myinfo[msg.sender].level >= 1,"no member"); 
      cya.approve(msg.sender,1e17);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= 1e17, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this),1e17);  
      myinfo[msg.sender].booster = 1e17;
      return true;
}   
function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

function g2() public view returns(
  uint256 allocya,uint256 exp,uint8 level,uint256 booster){  
   my storage tmy=myinfo[msg.sender];
  return ( tmy.allocya,
           tmy.exp,
           tmy.level,
           tmy.booster);
  }  
  function g3() public view virtual returns(uint256){  
  return cya.balanceOf(msg.sender);
  }
  function g4() public view virtual returns(uint){  
  return chart.length;
  }
    
  function g5(uint _num) public view virtual returns(uint256){  
  return chart[_num];
  }
 function g6() public view virtual returns(uint256){  
  return cat.balanceOf(address(this));
  }
  function g7(address user) public view virtual returns(uint256){  
  return cat.balanceOf(user);
  }
  function mentolength() public view returns(uint) { //geteps 호출용
  return mentolist.length;
  }

  function random() public view returns(uint){  //ver 1.1
    return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender))) % mentolength(); 
 }    
  function getmento(uint num) public view returns(address) {
  return mentolist[num];
    }
  function getmymento(address user)public view returns(address) {
      return mymento[user];
}
 function  levelcheck(address user)public view returns(uint8) {
      return myinfo[user].level;
  }
  function getprice() external view returns (uint256){
      return price; 
  }
  function geteps(address user) external view returns (uint256){  //다음 배당금
      return allow *g7(user) *myinfo[user].level/1000; 
  }
    } 