pragma solidity ^0.4.21;

import "./Racehorsehelper.sol";

contract RacehorseRacing is RacehorseHelper {
  uint randNonce = 0;
  uint attackVictoryProbability = 70;

  function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(now, msg.sender, randNonce)) % _modulus;
  }
}
