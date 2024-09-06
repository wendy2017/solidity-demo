// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Lottery {
  // 管理员地址
  address public manager;
  // 所有参与彩票的地址
  address[] public players;
  // 彩票期数
  uint public round;
  // 上一期的中奖地址
  address public winner;

  // 构造函数，部署合约时调用，将管理员设置为合约的创建者
  constructor() {
    manager = msg.sender;
  }

  // 参与彩票的函数
  function play() public payable {
    require(msg.value == 1 * 10 ** 18);
    players.push(msg.sender);
  }

  // 管理员开奖的函数
  function draw() public onlyManager {
    // 随机生成一个哈希值来确定中奖者
    // 通过难度值、时间戳和彩民人数来生成随机数的种子
    bytes memory info = abi.encodePacked(
      block.prevrandao, // 区块难度
      block.timestamp, // 当前区块时间戳
      players.length // 彩民人数
    );
    bytes32 hash = keccak256(info); // 计算哈希值
    uint index = uint(hash) % players.length; // 根据哈希值和玩家数量计算中奖者索引
    winner = players[index]; // 确定中奖者
    payable(winner).transfer(address(this).balance); // 将合约余额转给中奖者
    // 清空彩民池，并将期数加1
    delete players;
    round++;
  }

  // 管理员退奖的函数
  function undraw() public onlyManager {
    // 遍历所有彩民，将每人转账1 ether
    for (uint256 i = 0; i < players.length; i++) {
      payable(players[i]).transfer(1 ether);
    }
    // 清空彩民池，并将期数加1
    delete players;
    round++;
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  // 获取当前所有彩民的地址
  function getPlayers() public view returns (address[] memory) {
    return players;
  }

  // 修饰符，仅允许管理员执行相关函数
  modifier onlyManager() {
    require(msg.sender == manager);
    _;
  }
}
