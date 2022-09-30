// SPDX-License-Identifier: MIT  
//ver1.0   테스트 시간 조정 할 것
pragma solidity >=0.7.0 <0.9.0;

interface Icya {     
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  }


interface Icut1{
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function getdepot(address user)external view returns(uint256);  //필요없지만 
  }

  interface Icyacoop{
  function levelcheck(address user)external view returns(uint8);
  function expup(address user,uint pay) external returns(bool);
}
    contract cut1allow {   //cut1 배당 및 거래 
      Icya cya;
      Icut1 cut1;
      Icyacoop cyacoop;  
      address cyatax;
      uint8 day;   //펀딩 마감 날짜
      string public web;
      uint256 goalcya;  //목표금액
      uint256 public price; 
      uint256 public allow; 
      address public admin;
      address public executor; //집행자
      uint8 success;  //펀딩성공여부
      bool buying;  //cut 구매할건지 여부
      mapping(address => uint256)public allocya;   //배당시간 
      mapping(address => uint256)public reservation; //예약 주식 수 
      mapping(uint256 => voting)public vs;
      uint256 public vid; //안건 수
    
          
    constructor(address _cya,address _cut1,address _cyacoop,uint256 _price) public {
      cya=Icya(_cya);
      cut1=Icut1(_cut1);
      cyacoop = Icyacoop(_cyacoop); 
      cyatax = _cyacoop;
      price = _price*1e12;  //1000입력시 $1
      goalcya = _price * 1e12 * 1e8;  //목표금액
      admin = msg.sender;
      executor = msg.sender;
      success = 1;
      }
  
struct voting{
uint256 vid;
string agenda; 
uint256 votes; //득표수
bool vote; //가결여부
mapping(address => bool) voter; //기존 투표자 여부
}

function creatvoting(string memory  _agenda) public {
    require(getsold() *5/100 <= g4(msg.sender),"little cut");  //잔고 여부 
    vs[vid].agenda = _agenda;
    vs[vid].vote = false;
    vid += 1;    
}
function vote(uint _vid) public returns(bool){
    voting storage tv = vs[_vid];
    require(1 <= g4(msg.sender),"little cut");  //잔고 여부 
    require(tv.vote == false,"vote end"); 
    require(tv.voter[msg.sender] == false,"already voting"); 
    tv.votes += g4(msg.sender);
    tv.voter[msg.sender] = true;
    if(tv.votes > getsold()*50/100){
      tv.vote = true;
    }
}
function funding(uint _num) public returns(bool) {    // 몇 주 살 건지?
   uint pay = _num * price; 
    require(goalcya >= pay + g1(),"sold out");  //잔고 여부 
    require(_num >=1,"no decimals");
    require(cya.balanceOf(msg.sender) >= pay,"no cya"); 
    require(cyacoop.levelcheck(msg.sender) >= 1,"no member"); 
    require(success == 1,"end"); 
      cya.approve(msg.sender, pay);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);  
        reservation[msg.sender] += _num;  //몇 개를 예약 했는지?
      return true;     
} 

function cutex( ) public returns(bool) { //펀딩 성공 후 cut 교환
    uint num = reservation[msg.sender];
    require(success == 2,"no succeeded");
    require(1 >= num,"no cut");  
    require(g3() >= num,"sold out");
      reservation[msg.sender] = 0 ;  
      cyacoop.expup(msg.sender,num*price);
      cut1.transfer(msg.sender,num);
      allocya[msg.sender] = block.timestamp;
      return true;     
}
function buycut1(uint _num) public returns(bool) {  //펀딩완료 후 남은 cut 판매
   uint pay = _num * price;
    require(g3() >= _num,"sold out");  
    require(_num >=1,"no decimals");
    require(cya.balanceOf(msg.sender) >= pay,"no cya"); 
    require(cyacoop.levelcheck(msg.sender) >= 1,"no member"); 
    require(success == 2,"not successful yet");  //2번이면 성공
      cya.approve(msg.sender, pay);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);  
       cut1.transfer(msg.sender,_num);
      allocya[msg.sender] = block.timestamp;
      return true;     
}

function sellcut1(uint num)public returns(bool){      //부동산 청산 시
    require(g4(msg.sender) >= num,"no cut");
    require(cyacoop.levelcheck(msg.sender) >= 1,"no member"); 
    require(buying == true,"no buying");   
    uint256  pay = num*price;  
    cya.transfer(msg.sender,pay);
    cut1.approve(msg.sender, num);
        uint256 allowance = cut1.allowance(msg.sender, address(this));
        require(allowance >= num, "Check the token allowance");
        cut1.transferFrom(msg.sender, address(this), num); 
    return true;
}


function buyingok(uint num)public returns(bool){
 require(executor == msg.sender,"no executor");  //집행자가 청산시 cut  구매여부를 결정
 if(num ==1) {buying = true;
}else if(num == 2) { buying = false;
}
}

function withdraw( )public returns(bool){   
    require (success == 2,"Funding failure");
    require(g4(msg.sender)>=1,"no cut"); 
    require(allocya[msg.sender] +  30  <  block.timestamp,"not time"); //주1회 테스트 30초
    uint256 pay = g4(msg.sender) * getallow() * 10/700;
     allocya[msg.sender] = block.timestamp;
     cya.transfer(msg.sender,pay);
    return true;
}

function getback( )public returns(bool){   //펀딩실패시 투자금 돌려주기
    uint256 cyaback = reservation[msg.sender] * price;
    require (success == 3,"no failure");
    require (cyaback <= g1(),"enough money");
    require (reservation[msg.sender] >= 1,"no reservation"); //투자금액
    reservation[msg.sender] = 0; 
    cya.transfer(msg.sender,cyaback);
    return true;
}

function adminex(address newadmin)public{
    require(admin == msg.sender);
    admin = newadmin;
}

function ending(uint8 _num)public {
 require(executor == msg.sender,"no executor");
 require(success == 1,"already ending");
 require(g1() >= goalcya * 50/100,"not enough money");
 success = _num;
 if(2==_num){
 cya.transfer(executor,g1()*80/100); //현물 구매
 cya.transfer(cyatax,g1()*10/100);
 }
}

function webup(string memory _newweb)public {
 require(admin == msg.sender);
 web = _newweb;
}

function executorup(address newexecutor)public {  //집행자 업
 require(admin == msg.sender);
 executor = newexecutor;
}

function priceup(uint _price )public {
    require(admin == msg.sender,"no admin");
    price = _price * 1e12;  //배당+현물 청산 가치
}
   
 function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

  function g2() public view virtual returns(uint256){  
  return cya.balanceOf(msg.sender);
  }
 
 function g3() public view virtual returns(uint256){  
  return cut1.balanceOf(address(this));
  }
  function g4(address user) public view virtual returns(uint256){  
  return cut1.balanceOf(user);
  }


  function getallow( ) public view virtual returns(uint256){  
  return g1() / getsold();
  }
  function getsold() public view virtual returns(uint256){  
  return  1e8 - g3();
  }
  function getreservation(address user) public view virtual returns(uint256){  
  return  reservation[user];
  }
  function buystatus() public view virtual returns(bool){  //구매상태
  return buying;
  }
  
 function getmyallow(address user) public view virtual returns(uint){ 
  return g4(user) * getallow() * 10/700;
  }

  function myallownext() external view returns (uint){
      return (allowt[msg.sender] + 7 days ) - block.timestamp;  //테스트 30초
  }
 
  function getvote(uint num) public view returns(
  uint256 vid,string memory agenda,uint256 votes,bool vote){  
  voting storage tv = vs[num];
   return ( tv.vid,
           tv.agenda,
           tv.votes,
           tv.vote);
  }  
  
}