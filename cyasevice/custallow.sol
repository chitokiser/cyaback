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

interface Icust{
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function getdepot(address user)external view returns(uint256);
  }

  
    contract custallow {
      Icya cya;
      Icyacoop cyacoop;
      Icust cust;
      uint8 public status;
      uint256 public price; 
      uint256 public tax;
      uint256 public ip; //최초가격 발란싱
      uint256 public allow; 
      uint256[]public chart; 
      address public admin;
      address cyacoopt;
     mapping(address => uint8 )public fa;

    
    constructor(address _cya,address _cyacoop,address _cust,uint256 _allow,uint256 _ip) public {
      price=_ip * 1e12;  //사업 사이즈에 맞춰 최초가격 설정
      ip = _ip * 1e12;
      cya=Icya(_cya);
      cyacoop = Icyacoop(_cyacoop);
      cust=Icust(_cust); 
      cyacoopt = _cyacoop;  
      allow=_allow * 1e12;
      admin=msg.sender;
      }
    


function buycust(uint _num) public returns(bool) {  
   uint pay = _num * price;
    require(g6() >= _num,"sold out");  
    require(_num >=1,"no decimals");
    require(cya.balanceOf(msg.sender) >= pay,"no cya"); 
    require(cyacoop.levelcheck(msg.sender)>= 1,"no meber"); 
      cya.approve(msg.sender, pay);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);  
       cust.transfer(msg.sender,_num);
      allowt[msg.sender] = block.timestamp;
      priceup();
      tax += pay * 10/100;
      return true;     
}

function sellcust(uint _num)public returns(bool){      //한번에 파는게아닌 일부만 팔 수 있음 
    require(status >= 2,"not state");  //매수 현황설정 가능
    require(g7(msg.sender) >= _num,"no cust");
    require(ip < price,"price low"); 
    require(cust.getdepot(msg.sender) + 365 days  <  block.timestamp,"not time");   
  uint256  pay = _num*price;  
    cya.transfer(msg.sender,pay);
    cust.approve(msg.sender, _num);
        uint256 allowance = cust.allowance(msg.sender, address(this));
        require(allowance >= _num, "Check the token allowance");
        cust.transferFrom(msg.sender, address(this), _num); 
    priceup();
    return true;
}

function winmoneywithdraw( )public returns(bool){   //복권 당첨금 인출
    require(winm[msg.sender] >=1,"no winmoney");
    require(g1()>=winm[msg.sender],"no cya");  
    require(status >= 3,"no state");  
    uint pay = winm[msg.sender];
    winm[msg.sender] = 0;
     cyacoop.expup (msg.sender,g7(msg.sender) * pay/1e12);//pay*cust보유량 만큼 경험치 보너스 제공
    cya.transfer(msg.sender,pay);
    return true;
}

function winmup(address user,uint amount)public returns(bool){
    require(fa[msg.sender] >= 5,"no family");
    winm[user] += amount;
    return true;
}
function faup(address _fa,uint8 _num)public{
    require(admin == msg.sender,"no admin");
    fa[_fa] = _num;
}
function withdraw( )public returns(bool){   
    require(g7(msg.sender)>=1,"no cust"); 
    require(allowt[msg.sender] + 7 days   <  block.timestamp,"not time"); //주1회
     require(status >= 1,"no state");  
    uint256 pay = g7(msg.sender)*allow * getlevel(msg.sender)/1000;  
    allowt[msg.sender] = block.timestamp;
    cya.transfer(msg.sender,pay);
     if(tax >= 1e18){ 
   cya.transfer(cyacoopt,tax);
   tax =0;
   }
    return true;
}

function adminex(address newadmin)public{
    require(admin == msg.sender,"no admin");
    admin = newadmin;
}
function statusup(uint8 _num)public {
 require(admin == msg.sender,"no admin");
 status = _num;
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
  return ((allowt[msg.sender] + 7 days) - block.timestamp);
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
  return cust.balanceOf(address(this));
  }
  function g7(address user) public view virtual returns(uint256){  
  return cust.balanceOf(user);
  }
  function getlevel(address user) public view virtual returns(uint256){  
  return cyacoop.levelcheck(user);
  }

  function getprice() external view returns (uint256){
      return price; 
  }
  function geteps(address user) external view returns (uint256){  //다음 배당금
      return allow *g7(user) * getlevel(user)/1000; 
  }
    } 