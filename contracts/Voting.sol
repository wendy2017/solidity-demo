// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract Voting {
    // 记录哪些地址是选民
    mapping(address => bool) public voters;

    // 选项结构体
    struct Choice {
        uint id; // 选项ID
        string name; // 选项名称
        uint votes; // 选项的票数
    }

    // 投票单结构体
    struct Ballot {
        uint id; // 投票单ID
        string name; // 投票单名称
        Choice[] choices; // 投票单中的选项
        uint end; // 投票截止时间
    }

    // 记录所有投票单
    mapping(uint => Ballot) public ballots;
    uint public nextBallotId; // 下一个投票单ID
    address public admin; // 合约管理员地址
    mapping(address => mapping(uint => bool)) public votes; // 记录选民对投票单的投票状态

    constructor() {
        admin = msg.sender; // 部署合约的地址成为管理员
    }

    // 仅管理员可以添加选民
    function addVoter(address _voter) external onlyAdmin {
        voters[_voter] = true;
    }

    // 仅管理员可以创建投票单
    function createBallot(
        string memory name,
        string[] memory choices,
        uint offset
    ) public onlyAdmin {
        Ballot storage newBallot = ballots[nextBallotId];
        newBallot.id = nextBallotId;
        newBallot.name = name;
        newBallot.end = block.timestamp + offset;

        // 创建选项并将其添加到投票单中
        for (uint i = 0; i < choices.length; i++) {
            newBallot.choices.push(Choice(i, choices[i], 0));
        }
        nextBallotId++;
    }

    // 选民进行投票
    function vote(uint ballotId, uint choiceId) external {
        require(voters[msg.sender] == true, "Only voters can vote"); // 确保调用者是选民
        require(
            votes[msg.sender][ballotId] == false,
            "Voter can only vote once for a ballot"
        ); // 确保每位选民只能对每个投票单投票一次
        // require(block.timestamp < ballots[ballotId].end, "Can only vote until ballot end date"); // 确保投票在投票截止时间之前

        votes[msg.sender][ballotId] = true; // 记录选民的投票状态
        ballots[ballotId].choices[choiceId].votes++; // 增加选项的票数
    }

    // 获取投票单的详细信息
    function getBallot(uint ballotId) external view returns (Ballot memory) {
        return ballots[ballotId];
    }

    // 获取投票结果，只有在投票结束后才能查看
    function results(uint ballotId) external view returns (Choice[] memory) {
        // require(block.timestamp >= ballots[ballotId].end, "Cannot see the ballot result before ballot end"); // 确保只能在投票结束后查看结果
        return ballots[ballotId].choices;
    }

    // 限定只有管理员可以调用的修饰符
    modifier onlyAdmin() {
        require(msg.sender == admin, "You are not the admin");
        _;
    }
}
