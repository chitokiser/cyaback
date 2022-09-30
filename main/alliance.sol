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

interface Icyadex{
  function shoperup(address user,uint256 pay)external returns(bool);
}

interface Icyacoop{
  function levelcheck(address user)external view returns(uint8);
  function expup(address user,uint pay) external returns(bool);
}
    
    contract alliance{  
      Icya cya;
      Icyadex cyadex;
      Icyacoop cyacoop;
      address admin;
      address cyatax;
    
        mapping(address => uint) public mypoint;  //사용자 잭팟
        mapping(uint256 => shop) public ss;  //가맹점 리스트
        mapping(uint256 => cut) public cs;  //cut 리스트 
        mapping(address => uint8) public staff;
        uint256 public sindex;   //가맹점 shop index
        uint256 public cindex;  //CUTindex
      event jockpot(uint256 jack);
    
    constructor(address _cya,address _cyadex,address _cyacoop) public {
      cya = Icya(_cya);
      cyadex = Icyadex(_cyadex);
      cyacoop = Icyacoop(_cyacoop);
      cyatax = _cyacoop;
      admin = msg.sender;
      staff[msg.sender] = 5;
      }

    struct cut{
    uint256 cid; 
    address owner;
    string name; 
    address cutallow;  //어디에 세금을 입금하는지
    uint [] myshop;
    }

    struct shop{
    uint256 depo;
    uint256 sid;  //가맹점 아이디
    uint256 bc;  //업종 코드
    uint256 cc;  //국가코드
    address owner;
    uint mycid; //소속 아이디
    uint8 cr;  //포인트 백 비율
    uint8 pr;  //allow수수료 pr/1000
    uint8 status;  //상태
    string name; 
    string web;
    string metainfo; 
    }
   
function staffup (address _new,uint8 _num)public{
   require (admin == msg.sender,"no admin"); 
   staff[_new] = _num;
}

function shopinfoup(uint256 _cid,uint256 _sid,uint8 _cr,uint8 _pr,uint256 _bc,uint256 _cc,string memory _name,string memory _web,
address _owner,string memory _metainfo)public {  //샵 정보 변경
        require (cs[_cid].owner == msg.sender,"no owner"); //해당샵 종목   클럽 오너 여부
        require (_cr >= 1,"cr low");
        require (_cr <= 90,"cr hi");
        ss[_sid].cr = _cr;
        ss[_sid].pr = _pr; //가맹점 수수료
        ss[_sid].bc = _bc; //비즈니스 코드
        ss[_sid].cc = _cc; //국가코드
        ss[_sid].name = _name;
        ss[_sid].web = _web;
        ss[_sid].owner = _owner;
        ss[_sid].metainfo = _metainfo;     
}

function creatshop(uint8 _cr,uint _cid,string memory _name,address _owner,string memory _metainfo,uint8 _pr,
                  uint _bc,uint _cc,string memory _web)public {  //샵은 종목오너가  생성가능
        require (staff[msg.sender] >= 5,"no staff"); //staff면 가맹점 등록
        require (_cr >= 1,"cr low");
        require (_cr <= 90,"cr hi");
        ss[sindex].cr = _cr;  //캐쉬백 수수료
        ss[sindex].name = _name;
        ss[sindex].sid = sindex; //전역변수
        ss[sindex].owner = _owner;
        ss[sindex].mycid = _cid;  //나의 클럽 전역cid 주의
        ss[sindex].metainfo = _metainfo; //이미지 화일
        ss[sindex].pr = _pr; //가맹점 수수료
        ss[sindex].bc = _bc; //비즈니스 코드
        ss[sindex].cc = _cc; //국가코드
        ss[sindex].web = _web;
        ss[sindex].status = 1; //초기값 1
        cut storage tc =  cs[_cid];
        tc.myshop.push(sindex);  //클럽의 가맹점 리스트
        sindex += 1;
}
function shopstatusup (uint256 _sid,uint8 _num)public{  //샵 상태 업
   require (staff[msg.sender] >= 5,"no  staff");  //스태프가 변경가능
   ss[_sid].status = _num; 
}

function creatcyacut(string memory _name,address _cutallow,address _owner)public {   //종목 추가는 스태프가 생성가능
        require (staff[msg.sender] >= 5,"no staff");
        cs[cindex].name = _name;
        cs[cindex].cid = cindex;
        cs[cindex].owner = _owner;
        cs[cindex].cutallow = _cutallow;
        cindex += 1;
}

function buy(uint256 _sid,uint256 _pay)public returns(bool){    //조합원 아니면 구매 안됨.
    require(ss[_sid].cr >= 1,"no shop"); 
    require(_pay >= 1e15,"little cya");  
    require(cya.balanceOf(msg.sender) >= _pay,"no cya"); 
      cya.approve(msg.sender, _pay);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= _pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), _pay);  
      ss[_sid].depo += _pay*(100-ss[_sid].cr)/100;
      mypoint[msg.sender] += _pay*ss[_sid].cr/100;
    return true;
}


function mypointex( )public returns(bool){  //소비자 마일리지 잭팟
    require(mypoint[msg.sender] >= 1e15,"point little"); 
    uint256 tp = mypoint[msg.sender]* 50/random();
    require(g1() >= tp*10,"cya little"); 
    mypoint[msg.sender] =0;
    cya.transfer(msg.sender,tp);  //당첨금
    cyacoop.expup(msg.sender,tp); //경험치
    emit jockpot(tp);
    return true;
}
function shopex(uint256 _sid)public returns(bool){     //샵오너 매출 인출
    require(ss[_sid].owner == msg.sender,"no owner");
    uint pay = ss[_sid].depo;
    require(cya.balanceOf(address(this)) >= pay,"not enough cya"); 
    ss[_sid].depo = 0;
    uint tpr = pay*ss[_sid].pr/1000;
    cya.transfer(msg.sender,pay-tpr);  //가맹점 수수료 제외 하고 이체
    uint tmycid = ss[_sid].mycid; 
    cya.transfer(cs[tmycid].cutallow,tpr); //해당 클럽에게 수수료 이체 
    cyadex.shoperup(msg.sender,pay);  //가맹점 바인낸스 교환 후 클럽에서 바이낸스 환전
    return true;
}


function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

function g2(uint256 _sid) public view returns(uint256 depo,uint256 sid,address owner,uint256 mycid,uint8 cr,
string memory name,string memory web, string memory metainfo){  
  shop storage ts = ss[_sid];  //스택이 너무 깊어서 에러남
  require(ts.status >= 1,"lack of status"); //샵상태가 0이면 출력 하지 않음
  return ( ts.depo,
           ts.sid,
           ts.owner,
           ts.mycid, //내가 속한종목
           ts.cr,
           ts.name,
           ts.web,
           ts.metainfo); 
  }  


function g3(uint256 _cid) public view returns(uint256 cid,address owner,string memory name,address cutallow){  
  return ( cs[_cid].cid,
           cs[_cid].owner,
           cs[_cid].name,
           cs[_cid].cutallow);
  }

 function g4() public view virtual returns(uint256){  
  return cya.balanceOf(msg.sender);
  }
  
  function getmyshoplength(uint _cid) public view virtual returns(uint256){  
  return cs[_cid].myshop.length;
  }

  function getmyshop(uint _cid,uint _num) public view virtual returns(uint256){  
  return cs[_cid].myshop[_num];
  }
  function random() public view returns(uint){ 
    return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender))) % 300 + 5; 
  }
  
  function getmypoint( )public view returns(uint256) {
      return mypoint[msg.sender];
  }
}
  
