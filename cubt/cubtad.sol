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


    contract cubtad{  //cut종류마다 하나씩 추가
      Icya cya;
      uint256 public tax;
      uint256 ta; //전체 광고개수 
      address cutowner;
      uint256 aid;
      address cutallow;  //광고비 이체 주소
      address admin;

 
  
    constructor(address _cya,address _cutallow,address _cutowner) public {
      cya=Icya(_cya);
      cutallow = _cutallow;
      cutowner = _cutowner;
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
    require( _period >= 1,"low day"); //광고 시간
    uint pay = adfee * _period;
    require(cya.balanceOf(msg.sender) >= pay,"little cya");  //설정된 1일 광고비 * 광고 기간
    cya.approve(msg.sender, pay);
        uint256 allowance = cya.allowance(msg.sender,cutallow);  //cut allow한테 직접 입금
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender,cutallow, pay);
        ads[aid].aid = aid;
        ads[aid].period = _period;
        ads[aid].start= block.timestamp;
        ads[aid].home = _home;
        ads[aid].metainfo = _metainfo;
        aid += 1;
}



function extensionofperiod(uint256 _period,uint256 aid )public {
    require(ads[aid].owner == msg.sender,"no owner"); 
     uint pay = adfee * _period;
    require(cya.balanceOf(msg.sender) >= pay,"little cya");  //설정된 1일 광고비 * 광고 기간
    cya.approve(msg.sender, pay);
     uint256 allowance = cya.allowance(msg.sender,cutallow);  //cut allow한테 직접 입금
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender,cutallow, pay);
        ads[aid].period += _period;
    
}

    
function addfeeup(uint256 _adfee) public{  
  require(staff[msg.sender] >= 5,"no staff"); 
  adfee =_adfee * 1e12; //1원단위 입력
  }

function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

function g2(uint256 num) public view returns(uint256 aid,uint256 period,uint256 start,address owner,string memory home,string memory metainfo){  
 require(ads[num].period + ads[num].start/60/60/24 > block.timestamp /60/60/24,"No advertising period");//광고 기간 체크
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
  
