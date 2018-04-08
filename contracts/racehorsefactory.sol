pragma solidity ^0.4.21;

import "./ownable.sol";
import "./safemath.sol";

contract RacehorseFactory is Ownable {
  uint randNonce = 0;
  using SafeMath for uint256;
  using SafeMath8 for uint8;

  event NewRacehorse(uint racehorseId, string name, uint dna);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint feedCooldownTime = 6 hours;
  uint raceCooldownTime = 1 days;

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
    uint8 eyes;
  }

  Racehorse[] public racehorses;

  mapping (uint => address) public racehorseToOwner;
  mapping (address => uint) ownerRacehorseCount;

  function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(now, msg.sender, randNonce)) % _modulus;
  }

  function _createRacehorse(string _name, uint _dna) internal {
    uint8 colorNum = uint8(randMod(16));
    uint8 maneNum = uint8(randMod(16));
    uint8 eyesNum = uint8(randMod(16));
    uint id = racehorses.push(Racehorse(_name, _dna, 1, uint32(now + feedCooldownTime), 5, 5, 1, 0, 0, colorNum, maneNum, eyesNum)) - 1;
    racehorseToOwner[id] = msg.sender;
    ownerRacehorseCount[msg.sender]++;
    emit NewRacehorse(id, _name, _dna);
  }


  function createRandomRacehorse(string _name) public {
    require(ownerRacehorseCount[msg.sender] == 0);
    uint randDna = randMod(dnaModulus);
    _createRacehorse(_name, randDna);
  }

}
