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

     interface Icaycoop{
      function levelcheck(address user)external view returns(uint8);
      function expup(address user,uint pay) external returns(bool);
}

    contract cyafarm {
      Icaycoop caycoop;
      Icya cya;
      address admin;
      address custallow;  // custallow에 tax 이체함
      uint256 public tax; 
      uint256 public remain; //나머지 설정 1~remain
      mapping(uint => tree) public port;   //fixnum  
      uint256 []pl; // fix 저장 배열 turn생성
  

      event farmnum(uint winnum); 
    constructor(address _caycoop,address _cya,address _custallow) public { 
      caycoop = Icaycoop(_caycoop);
      cya =Icya(_cya);
      custallow = _custallow;
      admin = msg.sender;
      remain = 12;
    }

    struct tree {
    uint256 depo;  
    uint256 depon; //portid
    uint256 start;
    }
   
function seeding(uint256 pay) public { 
  uint winnum = ranmod(); 
  uint portid = pl.length;
  tree storage newport = port[winnum];

    require(cya.balanceOf(msg.sender) >= pay,"little cya");  
    cya.approve(msg.sender, pay);
        uint256 allowance = cya.allowance(msg.sender,address(this));  
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender,address(this), pay);
        pl.push(winnum);
        mydepo[msg.sender] += pay;
        tax += pay*10/100;
        caycoop.expup(msg.sender,pay);
        newport.start = block.timestamp;
        emit farmnum(winnum);
        if(newport.depo>0){
         uint bonus = portid - newport.depon; 
         uint jack = newport.depo * (bonus+100)/100;
         myjack[newport.owner] += jack;  //보상완료
         mygain[newport.owner] += jack - newport.depo;
        newport.depo = pay;
        newport.depon = portid;
        newport.portn = winnum;
        newport.owner = msg.sender;  
      
      
        }else{
        newport.depo = pay;
        newport.depon = portid;  //웨이팅 수익을 주기 위해 필요
        newport.portn = winnum;
        newport.owner = msg.sender;
       
        }
  }


  function ranmod( ) internal returns(uint){
   return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender))) % remain+1; //전역변수 적용
 }

  function withdraw( )public {   
   uint pay = myjack[msg.sender];
   require(pay > 0,"no money");
   myjack[msg.sender] = 0;
   mywin[msg.sender] += pay; 
   cya.transfer(msg.sender,pay); 
   if(tax >= 1e18){ 
   cya.transfer(custallow,tax);
   tax =0;
   }
  }

  function taxup(address _custallow )public returns(bool) {   
   require(admin ==  msg.sender,"tax litttle");
   custallow = _custallow;
   return true;
  }
 function remainup(uint _remain)public  {   //myport에서 가져온 portid
   require(admin ==  msg.sender,"tax litttle");
   remain = _remain;
  }
  
 function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }
   
   function pllength() public view returns(uint) {
  return pl.length;
  }
   function getpl(uint num) public view returns(uint) {
  return pl[num]; //portid입렵 화분 넘버 출력
  }
  function allportinfo(uint num) public view returns(uint depo,uint depon,uint portn,address owner,uint start) {  //현재 상태의 포트정보 pl에서 가져온 윈넘입력
  return (port[num].depo,
          port[num].depon,  //포트생성순서
          port[num].portn,  //포트고정값
          port[num].owner,
          port[num].start);
  }  

 function getperiod(uint num) public view returns(uint) { //누적 상금액   
  require(port[num].start >1,"empty") ;
  return  block.timestamp - port[num].start;
  }  
 
  function getvalue(uint num) public view returns(uint) { //현재 가치   
  return port[num].depo* (pllength() - port[num].depon + 100)/100 ;
  }  
 function getmywin() public view returns(uint) { //수금  
  return mywin[msg.sender];
  }  

  function getmydepo() public view returns(uint) { 
  return mydepo[msg.sender];
  } 
   function getmyseedmoney() public view returns(uint) { //원금 미수금
  require(mydepo[msg.sender]>mywin[msg.sender],"all returned");
   return mydepo[msg.sender] - mywin[msg.sender];
  } 
   function getmyfarm(uint num) public view returns(uint) { //내가 가지고 있는 농장개수
  require(port[num].owner == msg.sender);
  return port[num].portn;   //내 농장 번호를  DOM에 저장
  } 
   function getmygain() public view returns(uint) { //나의 이익금
  return mygain[msg.sender];   //나의 이익금
  } 
  function getmyjack( ) public view returns(uint) { //수확물    
  return myjack[msg.sender];
  }  
  
}
  

