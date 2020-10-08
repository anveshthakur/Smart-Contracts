pragma solidity ^0.4.24;

contract Lottery{
    address[] public players; //dynamic array with player's address
    address public manager;
    
    constructor() public{
        manager = msg.sender;
    }
    
    //adding a function to add players and recieve the amount from the players
    function add_player() payable public{
        require(msg.value >= 0.01 ether); //checking if the value is greater than 0.01 eth
        players.push(msg.sender); //adding the address of the account that is sending the ether
    }
    
    function get_balance() public view returns(uint){
        require(msg.sender == manager); //checking if the function is called by manager or not
        return address(this).balance; // returns the contract balance
    }
    
    function random() public view returns(uint256){
      return uint256(keccak256(block.difficulty, block.timestamp, players.length));
    }   
    
    function select_winner() public returns (address) {
        require(msg.sender == manager);
        uint r = random();
        address winner;
        
        uint index = r % players.length;
        
        winner = players[index];
        
        //transfer the contract balance to the winner address
        winner.transfer(address(this).balance);
        
        players = new address[](0); //reseting the lottery 
        
        
        
    }
    
}
