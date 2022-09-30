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


interface Icat{
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function getdepot(address user)external view returns(uint256);
  }

  interface Icyacoop{
  function getprice() external view returns (uint256);
  }
 
    contract Cyaito {
      Icya cya;
      Icat cat;
      Icyacoop cyacoop;
      address public admin;
      address fortrans;


          
    constructor(address _cya,address _cat,address _cyacoop) public {
      cya=Icya(_cya);
      cat=Icat(_cat);
      cyacoop=Icyacoop(_cyacoop);
      fortrans = _cyacoop;
      admin = msg.sender;
      }
  
function buycat(uint _num,address mento) public returns(bool) {  
    uint256 pay = _num*cyacoop.getprice()*sale/100;
    require(target>= _num*110/100,"sold out");  
    require(cya.balanceOf(msg.sender) >= pay,"no cya"); 
    require(_num >=10,"no decimals");
    require(g3() >= _num*110/100,"no cat"); 
      cya.approve(msg.sender, pay);
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);  
        cat.transfer(msg.sender,_num);
        cat.transfer(mento,_num*10/100);
        target -= _num*110/100;
      return true;     
}


function saleset (uint8 _sr,uint256 _num) public  { 
    require(admin == msg.sender,"no admin");
    require(_num <= g3(),"no cat");
    sale = _sr;
    target = _num;
  }
function transcoop() public returns(bool) { 
    require(admin == msg.sender);
    uint256 pay = g1();
    cya.transfer(fortrans,pay);
    return true;
  }

function g1() public view virtual returns(uint256){  
  return cya.balanceOf(address(this));
  }

function g2() public view virtual returns(uint256){  
  return cya.balanceOf(msg.sender);
  }
function g3() public view virtual returns(uint256){  
  return cat.balanceOf(address(this));
  }
function g4() public view virtual returns(uint256){  
  return cat.balanceOf(msg.sender);
  }
function g5() public view virtual returns(uint256){  
  return target;
  }  
 function getsaleprice() public view virtual returns(uint256){  
  return cyacoop.getprice()*sale/100;
  } 
    } 
    