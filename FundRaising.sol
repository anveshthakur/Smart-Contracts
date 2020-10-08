pragma solidity ^0.4.24;

//now = block.timestamp

contract FundRaising{
    mapping(address => uint) public contributors;
    address public admin;
    uint public noofContributors;
    uint public minimumContribution;
    uint public deadline;
    uint public goal;
    uint public raisedAmount = 0;
    
    struct Request{
        string description;
        address recipient;
        uint value;
        bool completed;
        uint noofVoters;
        mapping(address => bool) voters;
    }
    
    Request[] public requests;
    
    event ContributeEvent(address ender, uint value);
    event CreateRequestEvent(string _description, address _recipient, uint value);
    event MakePaymentEvent(address recipient, uint value);
    
    constructor(uint _goal, uint _deadline) public {
        goal = _goal;
        deadline = now + _deadline;
        admin = msg.sender;
        minimumContribution = 10;
    }
    
    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }
    
    function contribute() public payable{
        require(now < deadline);
        require(msg.value >= minimumContribution);
        
        if(contributors[msg.sender] == 0){
            noofContributors++;
        }
        
        contributors[msg.sender] += msg.value;
        
        raisedAmount += msg.value;
        
        emit ContributeEvent(msg.sender, msg.value);
    }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function getrefund() public{
        require(now > deadline);
        require(raisedAmount < goal);
        require(contributors[msg.sender] > 0);
        
        address recipient = msg.sender;
        
        uint value = contributors[msg.sender];
        
        recipient.transfer(value);
        
        raisedAmount -= value;
        
        noofContributors--;
        
        contributors[recipient] = 0;
    }
    
    function createRequests(string _description, address _recipient, uint _value) onlyAdmin public {
        Request memory newRequest = Request({
            description : _description,
            recipient : _recipient,
            value : _value,
            completed : false,
            noofVoters : 0 
        });
        
        requests.push(newRequest);
        emit CreateRequestEvent(_description, _recipient, _value);
    }
    
    function voteRequest(uint index) public{
        
        Request storage thisRequest = requests[index];
        require(contributors[msg.sender] > 0);
        
        require(thisRequest.voters[msg.sender] == false); //every contributor is allowed to vote only once 
        
        thisRequest.voters[msg.sender] = true;
        thisRequest.noofVoters++;
    }
    
    function makePayment(uint index) public onlyAdmin{
         Request storage thisRequest = requests[index];
        require(thisRequest.completed == false);
        require(thisRequest.noofVoters > noofContributors / 2);
        thisRequest.recipient.transfer(thisRequest.value);    
        thisRequest.completed = true;
        
        emit MakePaymentEvent(thisRequest.recipient, thisRequest.value);
    }
    
}

