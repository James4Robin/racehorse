pragma solidity ^0.4.21;

import "./racehorsefactory.sol";


contract RacehorseGrow is RacehorseFactory {

  modifier onlyOwnerOf(uint _racehorseId) {
    require(msg.sender == racehorseToOwner[_racehorseId]);
    _;
  }

  function _triggerCooldown(Racehorse storage _racehorse) internal {
    _racehorse.readyTime = uint32(now + feedCooldownTime);
  }

  function _isReady(Racehorse storage _racehorse) internal view returns (bool) {
      return (_racehorse.readyTime <= now);
  }

  function feedRacehorse(uint _racehorseId) internal onlyOwnerOf(_racehorseId) {
    Racehorse storage myRacehorse = racehorses[_racehorseId];
    expGrow(_racehorseId, 20);
    _triggerCooldown(myRacehorse);
  }

  function expGrow(uint _racehorseId, uint8 num) internal{
    Racehorse storage myRacehorse = racehorses[_racehorseId];
    require(_isReady(myRacehorse));
    if(myRacehorse.exp + num >= 100){
        myRacehorse.exp = 0;
        myRacehorse.level = myRacehorse.level.add(1);
        myRacehorse.skill = myRacehorse.skill.add(1);
    }else{
        myRacehorse.exp = myRacehorse.exp.add(num);
    }
  }

  function skillGrow(uint _racehorseId, uint8 num) internal {
    if(num + racehorses[_racehorseId].skill > 100){
      racehorses[_racehorseId].skill = 100;
    }else{
      racehorses[_racehorseId].skill = racehorses[_racehorseId].skill + num;
    }
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
    require(myRacehorse.dex <= dex);
    require(myRacehorse.str <= str);
    require(myRacehorse.ada <= ada);
    myRacehorse.skill = uint8(myRacehorse.skill - growSkill);
    myRacehorse.dex = dex;
    myRacehorse.str = str;
    myRacehorse.ada = ada;
    myRacehorse.color = color;
    myRacehorse.mane = mane;
    myRacehorse.eyes = eyes;
  }
}
