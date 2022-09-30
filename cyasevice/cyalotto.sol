// SPDX-License-Identifier: MIT  
//1.2
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

interface Icustallow{
  function winmup(address _user,uint _payout)external returns(bool); //set기능의 경우 .반드시 bool값으로 반환해야 함
}
    contract cyalotto{  //로또 배당금 및 당첨금 한번에처리
      Icya cya;
      Icyacoop cyacoop;
      Icustallow custallow;
      address cyatax; //custallow에 등록수수료 이체 
      address admin;
      uint256 public round; //회차 
      uint256 public fee; //등록 요금
      uint8 public status; // 상태 1일때 복권등록 가능 추첨중일때 상태 0 
      mapping(address => uint[]) mylotto; //나의 로또 id
      mapping(address => uint8)staff;  //스태프 여부
      uint256 public lid;  //로또 아이디


     constructor(address _cya,address _cyacoop,address _custallow,uint256 _round,uint256 _fee) public {
      cya = Icya(_cya);
      cyacoop = Icyacoop(_cyacoop);
      custallow = Icustallow(_custallow);
      cyatax = _custallow; //수수료 이체
      round = _round; //최초등록 실제 로또 회차에 맞춰 등록
      admin = msg.sender;
      staff[msg.sender] = 5;
      fee = _fee; //패자 복권 등록비 설정
      }
   
struct lotto{
    uint256 id; //로또아이디
    address owner;
    uint256 lr; //로또회차
    bool claim; //청구여부
    bool sw; //스페샬 1등2등 청구여부
    uint[6]mynum; //로또번호
    uint mat; //당첨번호갯수
    uint depo; //당첨 수령액
}

struct ri{ //로또 회차별정보
 uint256 total; //이번라운드 참여 복권 총수
 uint256 depo; //이번라운드 지급금액
 uint[6]win; //이번 라운드 당첨번호
}

function lottoregi(uint _n1,uint _n2,uint _n3,uint _n4,uint _n5,uint _n6)public {  //유저가 지난주 로또 등록하기
        require( g5(msg.sender) >= 1,"Not have membership yet");  //cyacoop레벨 체크
        require( status == 1,"Not ready yet");
        require(g3(msg.sender) >= fee,"Not enough cya"); //등록수수료 초기무료
        require( _n1<_n2&&_n2<_n3&&_n3<_n4&&_n4<_n5&&_n5<_n6,"Numbers cannot be the same");//작은숫자부터 기입할것
        cya.approve(msg.sender, fee);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= fee, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this),fee);
        ls[lid].id = lid;
        ls[lid].owner = msg.sender;
        ls[lid].lr = round;
        ls[lid].mynum[0]= _n1;
        ls[lid].mynum[1] = _n2;
        ls[lid].mynum[2] = _n3;
        ls[lid].mynum[3] = _n4;
        ls[lid].mynum[4] = _n5;
        ls[lid].mynum[5] = _n6;
        mylotto[msg.sender].push(lid);
        lid += 1; //발행번호 추가
        ris[round].total += 1;
}
function drawing(uint _n1,uint _n2,uint _n3,uint _n4,uint _n5,uint _n6)public {  //이번주 추첨번호 
        require(staff[msg.sender] >= 3,"No staff");
        require(status == 0,"Can't access now");  //0상태 일때 신규등록 불가
        ris[round].win[0] = _n1;
        ris[round].win[1] = _n2;
        ris[round].win[2] = _n3;
        ris[round].win[3] = _n4;
        ris[round].win[4] = _n5;
        ris[round].win[5] = _n6;
        round += 1; //회차 추가
        status = 1; //등록 가능 모드
}

function claim(uint256 _id)public {    //복권아이디
    require(ls[_id].owner == msg.sender,"No permission"); //오너아님
    require(ls[_id].claim == false,"Already claimed"); //당첨금 청구여부
    require(ls[_id].depo == 0,"Already withdrawal"); //당첨금 인출여부
    require(round > ls[_id].lr,"Winning numbers is not ready"); //추첨여부 
    ls[_id].mat;
    uint tlr = ls[_id].lr; //해당 복권 회차정보
    for(uint i =0; i<6; i++){
        for(uint k =0; k<6; k++){
        if(ls[_id].mynum[i] == ris[tlr].win[k]){
        ls[_id].mat += 1;    
        }
    }
    }
    //보상
    uint payout = 0;
     uint lt = g5(msg.sender);
    if(ls[_id].mat == 4){ 
      payout = g4()/(1000 - lt);
     }
     else if(ls[_id].mat == 3)
     payout = g4()/(2500 - lt);
     else if(ls[_id].mat == 2)
     payout = g4()/(10000 - lt);
    
     ls[_id].depo = payout;
     ris[round].depo += payout;
     ls[_id].claim = true;
     custallow.winmup(msg.sender,payout);
}
 
function claimsw(uint256 _id,address _owner)public {   //특별보상 
    require(staff[msg.sender] >=5,"No staff"); //1등이나 2등은 스텝이 직접 보상
    require(ls[_id].owner == _owner,"No permission");
    require(ls[_id].sw == false,"Already claimed"); //스페샬 청구여부
    require(ls[_id].depo == 0,"Already withdrawal"); //당첨금 청구여부
    require(round > ls[_id].lr,"Winning numbers is not ready"); //추첨여부
    uint tmat = ls[_id].mat;
    uint tlr = ls[_id].lr;
    for(uint i =0; i<6; i++){
        for(uint k =0; i<k; k++){
        if(ls[_id].mynum[i] == ris[tlr].win[k] ){
        tmat += 1;    
        }
        }
    }
    uint payout = 0;
     uint lt = g5(msg.sender);
    if(ls[_id].mat == 5){ 
      payout = g4()/(250 - lt);
     }
     else if(ls[_id].mat == 6)
     payout = g4()/(50 - lt);
   
     ls[_id].depo = payout;
     ris[round].depo += payout;
     ls[_id].claim = true;
     custallow.winmup(msg.sender,payout);
}
function statusup(uint8 _num)public {    //상태변경 
    require(staff[msg.sender] >= 5,"No staff"); 
    status = _num;
}

function staffup(address _staff,uint8 _num)public {    //직원추가
    require(admin == msg.sender,"No admin"); 
    staff[_staff] = _num;
}
function feeup(uint256 _fee)public {    //직원추가
    require(staff[msg.sender] >=2 ,"No staff"); 
    fee = _fee; //등록비 변경
}

function roundup(uint256 _round)public {    //회차 수동변동
    require(staff[msg.sender] >=1 ,"No staff"); 
    round = _round; //등록비 변경
}

function feetransfer( )public {    //계약이 가지고 있는 cya 모두 custallow에게 이체 
    require(staff[msg.sender] >=1 ,"No staff"); 
    cya.transfer(cyatax,g1()); 
}

   
function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

function g2(uint256 _id) public view returns(uint256 ,address,uint256,bool,uint[6]memory,uint256,uint256){  
  return (ls[_id].id,
          ls[_id].owner,
          ls[_id].lr,
          ls[_id].claim,
          ls[_id].mynum,
          ls[_id].mat,
          ls[_id].depo);
  }  

  function g3(address user) public view virtual returns(uint256){  //수수료 이체전 유저잔고 확인방법
  return cya.balanceOf(user);
  }
   
  function g4() public view virtual returns(uint256){  //custallow잔고 확인
  return cya.balanceOf(cyatax);
  }
  
  function g5(address user) public view returns(uint){  //custallow에서 cyacoop을 통해 레벨정보 가져옴
  return cyacoop.levelcheck(user);
  }
  function getris(uint256 _round) public view returns(uint,uint,uint[6]memory){  
  return (ris[_round].total,
          ris[_round].depo,
          ris[_round].win);
  }  
  function mylottolength(address user) public view virtual returns(uint256){  
  return mylotto[user].length;
  }

  function getmylottoid(uint _num,address user) public view returns(uint){  
    return mylotto[user][_num]; 
 }    

 function getwinnum(uint _round)public view returns(uint[6]memory) {
      return ris[_round].win;

}


    }