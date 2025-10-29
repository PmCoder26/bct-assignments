// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Bank {
    mapping(address => uint256) private balances;

    
    event Deposit(address indexed user, uint256 amount);

    
    event Withdraw(address indexed user, uint256 amount);

    
    function deposit() external payable {
        require(msg.value > 0, "Zero deposit");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    
    function withdraw(uint256 amount) external payable  {    
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Effects: Update state before external call
        balances[msg.sender] = balances[msg.sender] - amount;

        // Interaction: Transfer ETH
        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount);
    }

    /// @return The user's balance in wei.
    function showBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
}
