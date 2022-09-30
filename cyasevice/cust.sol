// SPDX-License-Identifier: MIT
// ver1.0
pragma solidity >=0.7.0 <0.9.0;
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
   }

contract cust is IERC20 {  // 복권유틸리티토큰
    string public constant name = "CyaUtilitySeviceToken";
    string public constant symbol = "CUST";
    string public metainfo;
    uint8 public constant decimals = 0;
    uint public constant total = 1e8; //1억개
    address admin;
    bool mint; //딱 한번 토큰발행 가능
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address =>uint256)depot;


   constructor(string memory _metainfo) {
    admin = msg.sender;
    metainfo = _metainfo;  //토큰 상세 정보
    }

    function minting( )public{   //발행 토큰 수 고정 초기 배분율 조절 가능
    require(admin == msg.sender,"no admin");
    require(mint == false,"already minting");
     mint = true;
     balances[msg.sender] = total; 
   }
   
   function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        depot[receiver] = block.timestamp;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address owner, uint256 numTokens) public override returns (bool) {
        allowed[owner][msg.sender] = numTokens;
        emit Approval(owner, msg.sender, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]+numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    function getdepot(address user)public view returns(uint256){ 
        return depot[user];
  }

    function mycutbalances( ) public view returns(uint256) {
        return balanceOf(msg.sender);
}
}
