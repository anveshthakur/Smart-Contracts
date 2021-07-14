pragma solidity ^0.5.16;

contract TodoList{
    uint public taskCount = 0;
    
    constructor() public{
        createTasks("Inital Task");
    }

    struct Task{
        uint id;
        string content;
        bool complete;
    }

    event TaskCreated(
        uint id,
        string content,
        bool completed
    );

    event TaskCompleted(
        uint id,
        bool complete
    );

    mapping(uint => Task) public Tasks;

    function createTasks(string memory _content) public{
        taskCount++;
        Tasks[taskCount] = Task(taskCount, _content, false);
        emit TaskCreated(taskCount, _content, false);
    }

    function toggleComplete(uint _id) public{
        Task memory _task = Tasks[_id];
        _task.complete = !_task.complete;
        Tasks[_id] = _task;
        emit TaskCompleted(_id, _task.complete);
    }
}