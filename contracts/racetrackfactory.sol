pragma solidity ^0.4.21;

import "./ownable.sol";
import "./safemath.sol";
import "./racehorsefactory.sol";

contract RacetrackFactory is RacehorseFactory {
  uint randNonce = 0;
  using SafeMath for uint256;
  using SafeMath8 for uint8;

  event NewRacetrack(uint racehorseId, string name, string condition, uint8 degree);

  struct Racetrack {
    string name;
    string condition;
    uint8 degree;
  }

  Racetrack[] public racetracks;

  function createRacetrack(string _name, string condition, uint8 degree) external onlyOwner {
    uint id = racetracks.push(Racetrack(_name, condition, degree)) - 1;
    emit NewRacetrack(id, _name, condition, degree);
  }

  function getRondTrack() internal returns(uint){
    uint size = racetracks.length;
    return randMod(size);
  }
}
