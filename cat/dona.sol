// SPDX-License-Identifier: MIT  
//ver1.0
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

    contract dona {
      Icya cya;
      Icyacoop cyacoop; 
      address cyatex; //cyacoop 메소드
      uint256 public sum; 
      event jackpot(uint256 pay);
      
      constructor(address _cya,address _cyacoop) public {
      cya=Icya(_cya);
      cyacoop = Icyacoop(_cyacoop);
      cyatex = _cyacoop;
      }


function donation(uint256 num)public returns(bool){   

    require(cyacoop.levelcheck(msg.sender) >=1,"no member");
    require(cya.balanceOf(msg.sender) >= num,"no cya");
    require(1e15 <= num,"little");
    cya.approve(msg.sender,num);
    uint256 allowance = cya.allowance(msg.sender, address(this));
    require(allowance >= num, "Check the token allowance");
    cya.transferFrom(msg.sender, address(this), num);
    uint256 pay = num * random()/50; 
    cyacoop.expup(msg.sender,pay);
    sum += num; //누적기부금액
    emit jackpot(pay);
     if(g1() >= 1e19){
    cya.transfer(cyatex,g1());
    return true;
 }
}
function random() public view returns(uint){  
    return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender))) % 500 + 1; 
}
function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

function g3() public view virtual returns(uint256){  
  return cya.balanceOf(msg.sender);
  }
  
    } 