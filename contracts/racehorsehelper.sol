pragma solidity ^0.4.21;

import "./racehorsegrow.sol";

contract RacehorseHelper is RacehorseGrow {

  uint levelUpFee = 0.001 ether;

  modifier aboveLevel(uint _level, uint _racehorseId) {
    require(racehorses[_racehorseId].level >= _level);
    _;
  }

  function withdraw() external onlyOwner {
    owner.transfer(address(this).balance);
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _racehorseId) external payable {
    require(msg.value == levelUpFee);
    racehorses[_racehorseId].level++;
  }

  function skillUp(uint _racehorseId) external payable {
    require(msg.value == levelUpFee);
    racehorses[_racehorseId].skill++;
  }

  function changeName(uint _racehorseId, string _newName) external aboveLevel(2, _racehorseId) onlyOwnerOf(_racehorseId) {
    racehorses[_racehorseId].name = _newName;
  }

  function changeDna(uint _racehorseId, uint _newDna) internal onlyOwnerOf(_racehorseId){
    racehorses[_racehorseId].dna = _newDna;
  }

  function changeDna(uint _racehorseId, uint8 growSkill, string _species) external aboveLevel(20, _racehorseId) onlyOwnerOf(_racehorseId) {
    Racehorse storage myRacehorse = racehorses[_racehorseId];
    require(_skillCheck(myRacehorse, growSkill));
    if (keccak256(_species) == keccak256("last")) {
      myRacehorse.dna = myRacehorse.dna - myRacehorse.dna % 10 + (myRacehorse.dna/10 + growSkill) % 10;
    }else if (keccak256(_species) == keccak256("lastsecond")) {
      myRacehorse.dna = myRacehorse.dna - myRacehorse.dna % 100 + (myRacehorse.dna/100 + growSkill * 10) % 100;
    }
    myRacehorse.skill = myRacehorse.skill - growSkill;
    changeDna(_racehorseId, myRacehorse.dna);
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
