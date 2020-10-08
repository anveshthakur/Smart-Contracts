pragma solidity ^0.4.24;

contract AuctionCreator{
    address[] public auctions;
    
    function createAuction() public {
        address newAuction = new Auction(msg.sender);
        auctions.push(newAuction);
    }
}

contract Auction{
    address public Owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;
    
    enum State {Started, Running, Ended, Canceled}
    
    State public auctionState;
    
    uint public highestBindingBid;
    address public highestBidder;
    uint bidIncrement;
    
    mapping(address => uint) public bids;
    
    constructor(address creator) public{
        Owner = creator;
        auctionState = State.Running;
        startBlock = block.number;
        endBlock = startBlock + 40320;
        ipfsHash = "";
        bidIncrement = 10;
    }
    
    modifier notOwner(){
        require(msg.sender != Owner);
        _;
    }
    
    modifier inTime(){
        require(block.number >= startBlock && block.number < endBlock );
        _;
    }
    
    modifier onlyOwner()
    {
        require(msg.sender == Owner);
        _;
    }
    
    function min(uint a, uint b) pure internal returns(uint){
        if(a <= b){
            return a;
        }else{
            return b;
        }
    }
    
    
    function placeBid() public payable inTime notOwner returns(bool) {
        require(auctionState == State.Running);
        //require(msg.value > 0.001 ether);
        
        uint currentBid = bids[msg.sender]+msg.value;
        
        require(currentBid > highestBindingBid);
        
        bids[msg.sender] = currentBid;
        
        if(currentBid <= bids[highestBidder]){
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        }else{
            highestBindingBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = msg.sender;
        }
        
        return true;
    }
    
    function cancelAuction() public onlyOwner{
        auctionState = State.Canceled;
    }
    
    function FinalizeAuction() public {
        require(auctionState == State.Canceled || block.number > endBlock);
        
        require(msg.sender == Owner || bids[msg.sender] > 0);
        
        address recipient;
        uint value;
        
        if(auctionState == State.Canceled){
            recipient = msg.sender;
            value = bids[msg.sender];
        }else{
            if(msg.sender == Owner){
                recipient = Owner;
                value = highestBindingBid;
            }
            else{
                  if(msg.sender == highestBidder){
                      recipient = highestBidder;
                      value = bids[highestBidder]-highestBindingBid;
              }else{
                  recipient = msg.sender;
                  value = bids[msg.sender];
              }
            }
        }
       recipient.transfer(value); 
    }
    
}
    
