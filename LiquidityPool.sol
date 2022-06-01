// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

import "./openzeppelin-contracts/IERC20.sol";
import "./weighted-math/WeightedMath.sol";
import "./openzeppelin-contracts/SafeMath.sol";

contract LiquidityPool is WeightedMath {

  using SafeMath for uint256;

  IERC20 tokensA;
  IERC20 tokensB;
  uint256 balanceA;
  uint256 balanceB;
  uint256 weightA;
  uint256 weightB;
  uint256 startTime;
  uint256 fee;
  bool poolIsLaunched = false;


// Function is still not ready

function launchPool(address tokenA,
  address tokenB,
  uint256 durationDays,
  uint256 initialWeightA,
  uint256 initialWeightB,
  uint256 initialBalanceA,
  uint256 initialBalanceB,
  uint256 fee1) public{

    tokensA = IERC20(tokenA);
    tokensB = IERC20(tokenB);

    require(tokensA.allowance(msg.sender, address(this)) >= initialBalanceA);
    require(tokensB.allowance(msg.sender, address(this)) >= initialBalanceB);
    require(tokensA.transferFrom(msg.sender, address(this), initialBalanceA));
    require(tokensB.transferFrom(msg.sender, address(this), initialBalanceB));

    startTime = block.timestamp;
    fee = fee1;

    require(initialWeightA + initialWeightB == 1);

    weightA = initialWeightA;
    weightB = initialWeightB;

    poolIsLaunched = true;
}

function _getTokensA(uint256 amount) private returns(bool){
  tokensA.approve(address(this), amount);
  if(tokensA.allowance(msg.sender, address(this)) < amount){
    return false;
  }
  if(tokensA.transferFrom(msg.sender, address(this), amount)){
    return true;
  }
  return false;
}

function _getTokensB(uint256 amount) private returns(bool){
  tokensA.approve(address(this), amount);
  if(tokensB.allowance(msg.sender, address(this)) < amount){
    return false;
  }
  if(tokensB.transferFrom(msg.sender, address(this), amount)){
    return true;
  }
  return false;
}

function _transferTokensA(uint256 amount) private {
  require(balanceA >= amount);
  tokensA.transferFrom(address(this), msg.sender, amount);
}

function _transferTokensB(uint256 amount) private {
  require(balanceB >= amount);
  tokensB.transferFrom(address(this), msg.sender, amount);
}

function _swapTokensAtoB(uint256 amountIn, uint256 amountOut) private {
  require(amountOut <= balanceB);
  if(_getTokensA(amountIn)){
    _transferTokensB(amountOut);
  }
}

function _swapTokensBtoA(uint256 amountIn, uint256 amountOut) private {
  require(amountOut <= balanceA);
  if(_getTokensB(amountIn)){
    _transferTokensA(amountOut);
  }
}

}