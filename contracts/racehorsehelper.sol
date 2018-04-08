pragma solidity ^0.4.19;

import "./racehorsegrow.sol";

contract RacehorseHelper is RacehorseGrow {

  uint levelUpFee = 0.001 ether;

  modifier aboveLevel(uint _level, uint _racehorseId) {
    require(racehorses[_racehorseId].level >= _level);
    _;
  }

  function withdraw() external onlyOwner {
    owner.transfer(this.balance);
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _racehorseId) external payable {
    require(msg.value == levelUpFee);
    racehorses[_racehorseId].level++;
  }

  function changeName(uint _racehorseId, string _newName) external aboveLevel(2, _racehorseId) onlyOwnerOf(_racehorseId) {
    racehorses[_racehorseId].name = _newName;
  }

  function changeDna(uint _racehorseId, uint _newDna) internal onlyOwnerOf(_racehorseId){
    racehorses[_racehorseId].dna = _newDna;
  }

  function changeDna(uint _racehorseId, uint growSkill, string _species) external aboveLevel(20, _racehorseId) onlyOwnerOf(_racehorseId) {
    Racehorse storage myRacehorse = racehorses[_racehorseId];
    require(_skillCheck(myRacehorse, growSkill));
    uint sum = myRacehorse.dex + myRacehorse.str + myRacehorse.ada + myRacehorse.color + myRacehorse.mane + myRacehorse.eyes;
    uint growSkill = sumTag - sum;


    if (keccak256(_species) == keccak256("last")) {
      newDna = newDna - newDna % 10 + (newDna/10 + growSkill) % 10;
    }else if (keccak256(_species) == keccak256("lastsecond")) {
      newDna = newDna - newDna % 100 + (newDna/100 + growSkill * 10) % 100;
    }
    myRacehorse.skill = _racehorse.skill - growSkill;
    changeDna(_racehorseId, newDna);
  }

  function getRacehorsesByOwner(address _owner) external view returns(uint[]) {
    uint[] memory result = new uint[](ownerRacehorseCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < racehorses.length; i++) {
      if (racehorseToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

}
