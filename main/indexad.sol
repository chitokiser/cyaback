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


    contract indexad{  //index에게 게시되는 배너관리
      Icya cya;
      uint256 public tax;
      address cutowner;
      uint256 public aid; //광고 id
      address public cutallow;  //광고비 이체 주소 index는cyacoop
      address admin;
      uint8 public status;  //광고등록 제한을 위해 상태체크
      uint256  public adfee;  //광고비 초단위
      uint256 public cutline;// 광고 커트라인 앞쪽 랜덤에 더하기
 
 
  
    constructor(address _cya,address _cutallow) public {
      cya=Icya(_cya);
      cutallow = _cutallow;
      admin = msg.sender;
      staff[msg.sender] = 5;
      status = 5;
      }
   
    struct ad{  //광고 등록
    uint256 aid; //광고id
    uint256 period; //광고기간 입력값 초단위
    uint256 start; //광고 시작 시간
    address owner; //광고주
    string home; //광고주 홈페이지 링크
    string metainfo;  //광고 이미지 url
    bool review; //광고심의여부
    }


function creatad(uint256 _period,string memory _home,string memory _metainfo)public {    
    require( _period >= 2592000,"not enough"); //30일 이상
    uint pay = adfee * _period;
    require(cya.balanceOf(msg.sender) >= pay,"little cya");  //설정된 1초 광고비 * 광고 기간
    require(status >= 5,"so many ad");
    cya.approve(msg.sender, pay);
        uint256 allowance = cya.allowance(msg.sender,address(this));  //cut allow한테 직접 입금
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender,address(this), pay);
        ads[aid].aid = aid;
        ads[aid].period = _period;
        ads[aid].start= block.timestamp;
        ads[aid].home = _home;
        ads[aid].metainfo = _metainfo;
        ads[aid].owner = msg.sender;
        aid += 1;
        tax += pay;
        myads[msg.sender].push(aid);
        if(tax >= 1e18){ 
        cya.transfer(cutallow,tax);
        tax = 0;
        }
}

    
function addfeeup(uint256 _adfee) public{  
  require(staff[msg.sender] >= 5,"no staff"); 
  adfee =_adfee; //1wei단위 입력
  }
function cutallowup(address _cutallow) public{  //광고비 이체주소 변경
  require(staff[msg.sender] >= 5,"no staff"); 
  cutallow =_cutallow; //1wei단위 입력
  }
function staffup(address newstaff,uint num) public{  
  require(staff[msg.sender] >= 5,"no staff"); 
  staff[newstaff] = num; 
  }
function statusup(uint8 num) public{  
  require(staff[msg.sender] >= 5,"no staff"); 
  status = num; 
  }
function reviewup(uint num) public{  
  require(staff[msg.sender] >= 5,"no staff"); 
  ads[num].review = true; 
  }
  function cutlineup(uint _cutline) public{    //커트라인 랜덤에서 더하기
  require(staff[msg.sender] >= 5,"no staff"); 
  cutline = _cutline; 
  }

  function beforereview(uint256 num) public view returns(uint256 aid,uint256 period,uint256 start,address owner,
  string memory home,string memory metainfo,bool review){  
 return ( ads[num].aid,
          ads[num].period,
          ads[num].start,   
          ads[num].owner,
          ads[num].home,
          ads[num].metainfo,
          ads[num].review);
  }  
function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

function g2(uint256 num) public view returns(uint256 aid,uint256 period,uint256 start,address owner,string memory home,string memory metainfo){  
 require(ads[num].period + ads[num].start > block.timestamp,"No advertising period");//광고 기간 체크
 require(ads[num].review == true,"before the review");//광고 심의 여부
 return ( ads[num].aid,
          ads[num].period,
          ads[num].start,   
          ads[num].owner,
          ads[num].home,
          ads[num].metainfo);
  }  

  function g3() public view virtual returns(uint256){  
  return cya.balanceOf(msg.sender);
  }
function g4(uint256 num) public view virtual returns(uint256){  //남은 광고 시간
  return ads[num].start + ads[num].period - block.timestamp;
  }
 
  function random() public view returns(uint){ //받은 값을 아규먼트로 하여  g2실행
    return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender))) % aid +cutline; 
  }

function getmyadslength( ) public view virtual returns(uint256){  //나의 광고들
  return myads[msg.sender].length;
  }
function getmyads(uint num) public view virtual returns(uint256){  //나의 광고들
  return myads[msg.sender][num];  //aid출력
  }

}
  
