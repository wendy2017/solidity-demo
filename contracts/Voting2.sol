// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

// 1.添加候选人 2.任何人都可给候选人投票（此时不做限制，故没有添加投票人这一函数）
// 3.统计各个候选的排名 4.纪录总票数，在本合约中即总投票人数

contract Voting {
  struct Candidate {
    uint id;
    string name;
    uint voteCount;
  }
  Candidate[] public candidates;
  //纪录某个投票人是否已经投过
  mapping(address => bool) public votes;
  uint public totalVoters;
  uint public votingEndTime;
  address public admin;

  //设置多长时间后失效
  constructor(uint _durationInMinutes) {
    admin = msg.sender;
    votingEndTime = block.timestamp + (_durationInMinutes * 1 minutes);
  }

  modifier onlyOwner() {
    require(msg.sender == admin, 'not owner');
    _;
  }
  modifier candidateIsValid(uint _candidateId) {
    require(_candidateId < candidates.length, 'candidate is unvalid');
    _;
  }
  modifier voterHasVoted() {
    require(!votes[msg.sender], 'you have already voted');
    _;
  }

  // 检查投票是否已经结束
  function isVotingClosed() public view returns (bool) {
    // 检查当前时间是否超过投票截止日期
    return block.timestamp >= votingEndTime;
  }

  // 只有合约部署者才可添加候选人
  function addCandidates(string memory name) external onlyOwner {
    candidates.push(Candidate(candidates.length, name, 0));
  }

  //1.候选者存在 2.该投票人未投过票 3.未超过投票时间
  function vote(
    uint _candidateId
  ) external candidateIsValid(_candidateId) voterHasVoted {
    require(block.timestamp < votingEndTime, 'Voting has ended');
    candidates[_candidateId].voteCount++;
    votes[msg.sender] = true;
    totalVoters++;
  }

  function getCandidateVoteCount(
    uint _candidateId
  ) public view candidateIsValid(_candidateId) returns (uint voteCount) {
    return candidates[_candidateId].voteCount;
  }

  //获取候选人总数
  function getCandidateCount() public view returns (uint candidateCount) {
    candidateCount = candidates.length;
  }

  function getCurrentCandidateRanking()
    public
    view
    returns (Candidate[] memory)
  {
    Candidate[] memory _candidates = candidates;
    // 对_candidates数组根据voteCount大小进行排序
    for (uint i = 0; i < _candidates.length - 1; i++) {
      for (uint j = 0; j < _candidates.length - i - 1; j++) {
        if (_candidates[j].voteCount < _candidates[j + 1].voteCount) {
          (_candidates[j], _candidates[j + 1]) = (
            _candidates[j + 1],
            _candidates[j]
          );
        }
      }
    }

    return _candidates;
  }
}
