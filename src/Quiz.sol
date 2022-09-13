// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    mapping(uint => mapping(address => uint256)) public bets;
    uint public vault_balance;
    mapping(address => uint256) bal;
    Quiz_item[] public quiz_list;
    address owner;

    constructor () {
        owner = msg.sender;
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        require(owner == msg.sender);
        quiz_list.push(q);
    }

    function getAnswer(uint quizId) public view returns (string memory){
        return quiz_list[quizId].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory q = quiz_list[quizId];
        q.answer="";
        return q;
    }

    function getQuizNum() public view returns (uint){
        return quiz_list.length-1;
    }
    
    function betToPlay(uint quizId) public payable {
        uint256 eth_val = msg.value;
        Quiz_item memory q = quiz_list[quizId];

        require(q.max_bet >= eth_val);
        require(q.min_bet <= eth_val);

        bets[quizId-1][msg.sender]+=msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        Quiz_item memory q = quiz_list[quizId];
        if(keccak256(abi.encodePacked(q.answer)) == keccak256(abi.encodePacked(ans)))
        {
            bal[msg.sender]=q.min_bet*2;
            return true;
        }
        else
        {
            vault_balance+=bets[quizId-1][msg.sender];
            bets[quizId-1][msg.sender]=0;
            return false;
        }
    }

    function claim() public {
        uint256 balance = bal[msg.sender];
        bal[msg.sender]=0;
        (bool isSuccess,)=msg.sender.call{value:balance}("");
        assert(isSuccess);        
    }

    receive() external payable {
        vault_balance+=msg.value;
    }

}
