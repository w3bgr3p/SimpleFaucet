// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EthFaucet {
    address public owner;
    uint256 public withdrawAmount = 0.01 ether; // Сумма за один запрос
    uint256 public cooldownTime = 1 days; // Время между запросами
    
    mapping(address => uint256) public lastWithdrawTime;
    
    event Withdrawal(address indexed to, uint256 amount);
    event Deposit(address indexed from, uint256 amount);
    
    constructor() {
        owner = msg.sender;
    }
    
    function deposit() public payable {
        require(msg.value > 0, "Must send ETH");
        emit Deposit(msg.sender, msg.value);
    }
    
    function requestTokens() public {
        require(address(this).balance >= withdrawAmount, "Faucet is empty");
        require(
            block.timestamp >= lastWithdrawTime[msg.sender] + cooldownTime,
            "Wait before next request"
        );
        
        lastWithdrawTime[msg.sender] = block.timestamp;
        payable(msg.sender).transfer(withdrawAmount);
        
        emit Withdrawal(msg.sender, withdrawAmount);
    }
    
    function timeUntilNextRequest(address user) public view returns (uint256) {
        uint256 nextRequest = lastWithdrawTime[user] + cooldownTime;
        if (block.timestamp >= nextRequest) {
            return 0;
        }
        return nextRequest - block.timestamp;
    }
    
    function setWithdrawAmount(uint256 _amount) public {
        require(msg.sender == owner, "Only owner");
        withdrawAmount = _amount;
    }
    
    function setCooldownTime(uint256 _time) public {
        require(msg.sender == owner, "Only owner");
        cooldownTime = _time;
    }
    
    function withdrawAll() public {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }
    
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}
