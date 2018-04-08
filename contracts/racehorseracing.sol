pragma solidity ^0.4.21;

import "./racehorsehelper.sol";
import "./racetrackfactory.sol";

contract RacehorseRacing is RacehorseHelper, RacetrackFactory {
  uint randNonce = 0;
  uint attackVictoryProbability = 70;

  modifier playersCheck(uint num) {
    require(num >= 2);
    require(num <= 8);
    _;
  }

  function _triggerRaceCooldown(Racehorse storage _racehorse) internal {
    _racehorse.readyTime = uint32(now + raceCooldownTime);
  }

  function racing(uint _racehorseId, uint8 _cphorses) external onlyOwnerOf(_racehorseId) playersCheck(_cphorses){
    Racehorse storage myRacehorse = racehorses[_racehorseId];
    uint sum = myRacehorse.dex  + myRacehorse.str + myRacehorse.ada;
    uint[] memory cphorsesNum = getCPs(sum, _cphorses);
    uint racetrackId = RacetrackFactory.getRondTrack();
    bool res = getRacingResult(_racehorseId,cphorsesNum, racetrackId);
    if(res){
      myRacehorse.level++;
      skillGrow(_racehorseId, _cphorses);
    }else{
      expGrow(_racehorseId, 20);
    }
    _triggerRaceCooldown(myRacehorse);
  }

  function getRacingResult(uint _racehorseId, uint[] _cphorsesNum, uint _racetrackId) internal view returns(bool){
    uint myValue = getRacingValue(_racehorseId, _racetrackId);
    uint compValue = 0;
    for (uint i = 0; i < _cphorsesNum.length; i++) {
      uint value = getRacingValue(_cphorsesNum[i], _racetrackId);
      if(value > compValue){
        compValue = value;
      }
    }
    if(compValue <= myValue){
      return true;
    }
    return false;
  }

  function getRacingValue(uint _racehorseId,  uint _racetrackId) internal view returns(uint){
    Racehorse memory myRacehorse = racehorses[_racehorseId];
    Racetrack memory racetrack = racetracks[_racetrackId];
    uint res = myRacehorse.dex * 30 + myRacehorse.str * 30 + myRacehorse.ada * racetrack.degree;
    if (keccak256(racetrack.condition) == keccak256("str")){
      res = res + 100 * myRacehorse.str;
    }else if (keccak256(racetrack.condition) == keccak256("dex")){
      res = res + 100 * myRacehorse.dex;
    }
    return res;
  }
  function getCPs(uint _sum, uint8 _cphorses) internal view returns(uint[]){
    uint[] memory result = new uint[](_cphorses);
    uint8 counter = 0;
    uint resNum = 0;
    for (uint i = 0; i < racehorses.length; i++) {
      uint sum = racehorses[i].dex + racehorses[i].str + racehorses[i].ada;
      if (sum == _sum) {
        result[counter] = i;
        resNum++;
        counter++;
        if(counter == _cphorses){
          counter = 0;
        }
      }
    }
    require(resNum >= _cphorses);
    return result;
  }
}
