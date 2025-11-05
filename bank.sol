pragma solidity ^0.8.0;

contract Bank {

    struct Account {
        string name;
        address owner;
        uint256 balance;
        bool isActive;
    }

    mapping(address => Account) accounts;
    address[] private accountHolders;

    // events.
    event AccountCreated(address owner, string name);
    event AccountClosed(address owner, string name);
    event AmountDeposited(address owner, uint256 amount, uint256 newBalance);
    event AmountWithdrawal(address owner, uint256 amount, uint newBalance);

    // modifier.
    modifier onlyAccountHolder() {
        require(accounts[msg.sender].isActive, "No active account found for caller!");
        _;
    }
    
    // functions.
    
        // account creation.
    function createAccount(string memory _name) external {
        require(!accounts[msg.sender].isActive, "Account already exists!");
        require(bytes(_name).length > 0, "Name cannot be empty");

        accounts[msg.sender] = Account(
            {name: _name,
            owner: msg.sender,
            balance: 0,
            isActive: true}
        );
        accountHolders.push(msg.sender);

        emit AccountCreated(msg.sender, _name);
    }

        // amount deposit.
    function deposit() external payable onlyAccountHolder {
        require(msg.value > 0, "Amount should be greater than zero");
        Account storage account = accounts[msg.sender];
        account.balance += msg.value;

        emit AmountDeposited(msg.sender, msg.value, account.balance);
    }

        // amount withdrawal.
    function withdraw(uint256 amount) external onlyAccountHolder {
        Account storage account = accounts[msg.sender];
        require(amount > 0, "Invalid withdrawal amount");
        require(account.balance >= amount, "Insufficient balance");

        account.balance -= amount;
        payable(msg.sender).transfer(amount);        

        emit AmountWithdrawal(account.owner, amount, account.balance);
    }

        // get account details.
    function viewAccount() external view onlyAccountHolder returns (Account memory) {
        return accounts[msg.sender];
    }

        // get all accounts.
    function viewAllAccounts() external view onlyAccountHolder returns (Account[] memory) {
        uint256 activeCount = 0;

        for(uint256 i = 0; i < accountHolders.length; i++) {
            if(accounts[accountHolders[i]].isActive) {
                activeCount++;
            }
        }

        Account[] memory list = new Account[](activeCount);
        uint256 idx = 0;
        for(uint256 i = 0; i < accountHolders.length; i++) {
            Account memory account = accounts[accountHolders[i]];
            if(account.isActive) {
                list[idx++] = account;
            }
        }

        return list;
    }    

}
