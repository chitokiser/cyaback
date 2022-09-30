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

interface Icyacoop{
  function levelcheck(address user)external view returns(uint8);
  function expup(address user,uint pay) external returns(bool);
}

interface Icubt{
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function getdepot(address user)external view returns(uint256);
  }

  
    contract cut1allow {
      Icya cya;
      Icyacoop cyacoop;
      Icut1 cut1;
      uint8 public status;
      uint256 public price; 
      uint256 public ip; //최초가격 발란싱
      uint256 public allow; 

          
    constructor(address _cya,address _cyacoop,address _cut1,uint256 _allow,uint256 _ip) public {
      price=_ip;  //사업 사이즈에 맞춰 최초가격 설정
      ip = _ip;
      cya=Icya(_cya);
      cyacoop = Icyacoop(_cyacoop);
      cut1=Icut1(_cut1);   
      allow=_allow*1e12;
      admin=msg.sender;
      }
    
function ownerexit(uint _num)public{  //오너 지분을 팔고 사업을 조합으로 양도할 경우
    require(status >= 2,"no status");
    require(g7(owner) >= _num,"cut little" );
    require(owner == msg.sender,"no owner" );
      uint256  pay = _num*price;  
    cya.transfer(msg.sender,pay);
    cut1.approve(msg.sender, _num);
        uint256 allowance = cut1.allowance(msg.sender, address(this));
        require(allowance >= _num, "Check the token allowance");
        cut1.transferFrom(msg.sender, address(this), _num); 
    priceup();  
}

function buycut1(uint _num) public returns(bool) {  
   uint pay = _num * price;
    require(g6() >= _num,"sold out");  
    require(_num >=1,"no decimals");
    require(cya.balanceOf(msg.sender) >= pay,"no cya"); 
    require(cyacoop.levelcheck(msg.sender)>= 1,"no meber"); 
      cya.approve(msg.sender, pay);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);  
       cut1.transfer(msg.sender,_num);
      allocya[msg.sender] = block.timestamp;
      priceup();
      return true;     
}

function sellcut1(uint _num)public returns(bool){      //한번에 파는게아닌 일부만 팔 수 있음 
    require(status >= 1,"no status");  //매수 현황설정 가능
    require(g7(msg.sender) >= _num,"no cct");
    require(cyacoop.levelcheck(msg.sender) >=1,"no member"); 
    require(cut1.getdepot(msg.sender) + 365 days  <  block.timestamp,"not time");   
  uint256  pay = _num*price;  
    cya.transfer(msg.sender,pay);
    cut1.approve(msg.sender, _num);
        uint256 allowance = cut1.allowance(msg.sender, address(this));
        require(allowance >= _num, "Check the token allowance");
        cut1.transferFrom(msg.sender, address(this), _num); 
    priceup();
    return true;
}

function withdraw( )public returns(bool){   
    require(g1()>= ip * 10,000,000 ,"no base");  //시아 잔고가 설정값 만큼 있는지 여부 
    require(g7(msg.sender)>=1,"no cut1"); 
    require(allocya[msg.sender] + 7 days   <  block.timestamp,"not time"); //주1회
    uint256 pay = g7(msg.sender)*allow * getlevel(msg.sender)/1000;  
    allocya[msg.sender] = block.timestamp;
    cya.transfer(msg.sender,pay);
    return true;
}
function adminex(address newadmin)public{
    require(admin == msg.sender);
    admin = newadmin;
}
function statusup(uint8 _num)public {
 require(admin == msg.sender,"no admin");
 status = _num;
}
function ownerup(address _newowner)public {
 require(admin == msg.sender,"no admin");
 owner = _newowner;
}

function priceup( )public {
    uint sold = 1e8-g6();
    allow = g1()/sold; 
    price = allow + ip;  //잔고가 하나도 없기 때문 기본 ip값 부여
    chart.push(price);   
}

function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

function g2() public view returns(
  uint256 ){  //다음 배당까지 남은 시간
  return ((allocya[msg.sender] + 7 days) - block.timestamp);
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
  return cut1.balanceOf(address(this));
  }
  function g7(address user) public view virtual returns(uint256){  
  return cut1.balanceOf(user);
  }
  function getlevel(address user) public view virtual returns(uint256){  
  return cyacoop.levelcheck(user);
  }

  function getprice() external view returns (uint256){
      return price; 
  }
  function geteps(address user) external view returns (uint256){  //다음 배당금
      return allow *g7(user) * getlevel(msg.sender)/1000; 
  }
    } 