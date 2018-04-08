pragma solidity ^0.4.21;

import "./racehorsefactory.sol";


contract RacehorseGrow is RacehorseFactory {

  modifier onlyOwnerOf(uint _racehorseId) {
    require(msg.sender == racehorseToOwner[_racehorseId]);
    _;
  }

  function _triggerCooldown(Racehorse storage _racehorse) internal {
    _racehorse.readyTime = uint32(now + cooldownTime);
  }

  function _isReady(Racehorse storage _racehorse) internal view returns (bool) {
      return (_racehorse.readyTime <= now);
  }

  function feedRacehorse(uint _racehorseId) internal onlyOwnerOf(_racehorseId) {
    Racehorse storage myRacehorse = racehorses[_racehorseId];
    require(_isReady(myRacehorse));
    if(myRacehorse.exp >= 80){
        myRacehorse.exp = 0;
        myRacehorse.skill = myRacehorse.skill.add(1);
    }else{
        myRacehorse.exp = myRacehorse.exp.add(20);
    }
    _triggerCooldown(myRacehorse);
  }

  function _skillCheck(Racehorse storage _racehorse, uint growSkill) internal view returns (bool){
    return (_racehorse.skill >= growSkill);
  }

  function grow(uint _racehorseId, uint16 dex, uint16 str, uint16 ada, uint8 color, uint8 mane, uint8 eyes) external onlyOwnerOf(_racehorseId) {
    Racehorse storage myRacehorse = racehorses[_racehorseId];
    uint sumTag = dex + str + ada + color + mane + eyes;
    uint sum = myRacehorse.dex + myRacehorse.str + myRacehorse.ada + myRacehorse.color + myRacehorse.mane + myRacehorse.eyes;
    uint growSkill = sumTag - sum;
    require(_skillCheck(myRacehorse, growSkill));
    myRacehorse.skill = uint8(myRacehorse.skill - growSkill);
    myRacehorse.dex = dex;
    myRacehorse.str = str;
    myRacehorse.ada = ada;
    myRacehorse.color = color;
    myRacehorse.mane = mane;
    myRacehorse.eyes = eyes;
  }
}
