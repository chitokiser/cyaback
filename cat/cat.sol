// SPDX-License-Identifier: MIT
// ver1.2
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

contract cat is IERC20 {
    string public constant name = "CyaAllocationToken";
    string public constant symbol = "CAT";
    uint8 public constant decimals = 0;
    uint public constant total = 1e9;
    address admin;
    address cyacoop;



   constructor() {
    admin=msg.sender;  
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
 

    function mycatbalances() public view returns(uint256) {
        return balanceOf(msg.sender);
}
}
