// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketingSystem {
    address public owner;
    uint256 public ticketPrice;
    uint256 public totalTickets;
    uint256 public ticketsSold;

    mapping(address => uint256) public ticketsOwned;

    constructor(uint256 _ticketPrice, uint256 _totalTickets) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function buyTicket(uint256 _quantity) external payable {
        require(_quantity > 0, "Quantity must be greater than 0");
        require(ticketsSold + _quantity <= totalTickets, "Not enough tickets available");
        require(msg.value == ticketPrice * _quantity, "Incorrect Ether sent");

        ticketsOwned[msg.sender] += _quantity;
        ticketsSold += _quantity;
    }

    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
