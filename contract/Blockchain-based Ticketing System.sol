// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketingSystem {
    address public owner;
    uint256 public ticketPrice;
    uint256 public totalTickets;
    uint256 public ticketsSold;
    bool public isPaused;

    mapping(address => uint256) public ticketsOwned;

    event TicketPurchased(address indexed buyer, uint256 quantity);
    event TicketTransferred(address indexed from, address indexed to, uint256 quantity);
    event TicketRefunded(address indexed holder, uint256 quantity);
    event FundsWithdrawn(address indexed owner, uint256 amount);
    event TicketPriceChanged(uint256 oldPrice, uint256 newPrice);
    event TotalTicketsChanged(uint256 oldTotal, uint256 newTotal);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractPaused(bool isPaused);
    event TicketBurned(address indexed holder, uint256 quantity);
    event EmergencyWithdrawal(address indexed owner, uint256 amount);

    constructor(uint256 _ticketPrice, uint256 _totalTickets) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;
        isPaused = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused, "Ticket sales are paused");
        _;
    }

    function buyTicket(uint256 _quantity) external payable whenNotPaused {
        require(_quantity > 0, "Quantity must be greater than 0");
        require(ticketsSold + _quantity <= totalTickets, "Not enough tickets available");
        
        uint256 priceToPay = ticketPrice * _quantity;

        // Discount: 5% off if buying 5 or more tickets
        if (_quantity >= 5) {
            priceToPay = (priceToPay * 95) / 100;  // 5% discount
        }

        require(msg.value == priceToPay, "Incorrect Ether sent");

        ticketsOwned[msg.sender] += _quantity;
        ticketsSold += _quantity;

        emit TicketPurchased(msg.sender, _quantity);
    }

    function getAvailableTickets() external view returns (uint256) {
        return totalTickets - ticketsSold;
    }

    function transferTicket(address _to, uint256 _quantity) external {
        require(_quantity > 0, "Quantity must be greater than 0");
        require(ticketsOwned[msg.sender] >= _quantity, "Not enough tickets to transfer");

        ticketsOwned[msg.sender] -= _quantity;
        ticketsOwned[_to] += _quantity;

        emit TicketTransferred(msg.sender, _to, _quantity);
    }

    function refundTicket(uint256 _quantity) external {
        require(_quantity > 0, "Quantity must be greater than 0");
        require(ticketsOwned[msg.sender] >= _quantity, "Not enough tickets to refund");

        ticketsOwned[msg.sender] -= _quantity;
        ticketsSold -= _quantity;

        uint256 refundAmount = ticketPrice * _quantity;
        payable(msg.sender).transfer(refundAmount);

        emit TicketRefunded(msg.sender, _quantity);
    }

    function withdrawFunds() external onlyOwner {
        uint256 amount = address(this).balance;
        payable(owner).transfer(amount);
        emit FundsWithdrawn(owner, amount);
    }

    function setTicketPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice > 0, "Price must be greater than zero");
        uint256 oldPrice = ticketPrice;
        ticketPrice = _newPrice;
        emit TicketPriceChanged(oldPrice, _newPrice);
    }

    function setTotalTickets(uint256 _newTotal) external onlyOwner {
        require(_newTotal >= ticketsSold, "Cannot set less than tickets already sold");
        uint256 oldTotal = totalTickets;
        totalTickets = _newTotal;
        emit TotalTicketsChanged(oldTotal, _newTotal);
    }

    function checkTickets(address _user) external view returns (uint256) {
        return ticketsOwned[_user];
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        address previousOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    // ✅ NEW FUNCTIONS

    function pauseContract(bool _pause) external onlyOwner {
        isPaused = _pause;
        emit ContractPaused(_pause);
    }

    function burnTickets(uint256 _quantity) external {
        require(_quantity > 0, "Quantity must be greater than 0");
        require(ticketsOwned[msg.sender] >= _quantity, "Not enough tickets to burn");

        ticketsOwned[msg.sender] -= _quantity;
        ticketsSold -= _quantity;

        emit TicketBurned(msg.sender, _quantity);
    }

    function viewContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
        emit EmergencyWithdrawal(owner, balance);
    }
}

   
   
   
      
