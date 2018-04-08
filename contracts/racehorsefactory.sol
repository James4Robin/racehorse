pragma solidity ^0.4.19;

import "./ownable.sol";
import "./safemath.sol";

contract RacehorseFactory is Ownable {
  uint randNonce = 0;
  using SafeMath for uint256;

  event NewRacehorse(uint racehorseId, string name, uint dna);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint cooldownTime = 6 hours;

  struct Racehorse {
    string name;
    uint dna;
    uint32 level;
    uint32 readyTime;
    uint16 dex;
    uint16 str;
    uint16 ada;
    uint8 exp;
    uint8 skill;
    uint8 color;
    uint8 mane;
    unit8 eyes;
  }

  Racehorse[] public racehorses;

  mapping (uint => address) public racehorseToOwner;
  mapping (address => uint) ownerRacehorseCount;

  function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(now, msg.sender, randNonce)) % _modulus;
  }

  function _createRacehorse(string _name, uint _dna) internal {
    uint colorNum = randMod(16);
    uint maneNum = randMod(16);
    uint eyesNum = randMod(16);
    uint id = racehorses.push(Racehorse(_name, _dna, 1, uint32(now + cooldownTime), 5, 5, 1, 0, 0, colorNum, maneNum, eyesNum)) - 1;
    racehorseToOwner[id] = msg.sender;
    ownerRacehorseCount[msg.sender]++;
    NewRacehorse(id, _name, _dna);
  }


  function createRandomRacehorse(string _name) public {
    require(ownerRacehorseCount[msg.sender] == 0);
    uint randDna = randMod(dnaModulus);
    _createRacehorse(_name, randDna);
  }

}
