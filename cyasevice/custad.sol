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


    contract custad{  //cust page 게시되는 배너관리
      Icya cya;
      uint256 public tax;
      address cutowner;
      uint256 public aid; //광고 아이디
      address public cutallow;  //광고비 이체 주소
      address admin;

 
  
    constructor(address _cya,address _cutallow) public {
      cya=Icya(_cya);
      cutallow = _cutallow;
      admin = msg.sender;
      staff[msg.sender] = 5;
      }
   
    struct ad{  //광고 등록
    uint256 aid; //광고id
    uint256 period; //광고기간 입력값 초단위
    uint256 start; //광고 시작 시간
    address owner; //광고주
    string home; //광고주 홈페이지 링크
    string metainfo;  //광고 이미지 url
    }


function creatad(uint256 _period,string memory _home,string memory _metainfo)public {    
    require( _period >= 1,"not enough"); //광고 시간
    uint pay = adfee * _period;
    require(cya.balanceOf(msg.sender) >= pay,"little cya");  //설정된 1초 광고비 * 광고 기간
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
        if(tax >= 1e18){ 
        cya.transfer(cutallow,tax);
        tax = 0;
        }
}

    
function addfeeup(uint256 _adfee) public{  
  require(staff[msg.sender] >= 5,"no staff"); 
  adfee =_adfee; //1wei단위 입력
  }

function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

function g2(uint256 num) public view returns(uint256 aid,uint256 period,uint256 start,address owner,string memory home,string memory metainfo){  
 require(ads[num].period + ads[num].start > block.timestamp,"No advertising period");//광고 기간 체크
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


}
  
