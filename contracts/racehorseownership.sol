pragma solidity ^0.4.21;

import "./racehorseracing.sol";
import "./erc721.sol";
import "./safemath.sol";

/// TODO: Replace this with natspec descriptions
contract RacehorseOwnership is RacehorseRacing, ERC721 {

  mapping (uint => address) racehorseApprovals;

  function balanceOf(address _owner) public view returns (uint256 _balance) {
    return ownerRacehorseCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return racehorseToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerRacehorseCount[_to] = ownerRacehorseCount[_to].add(1);
    ownerRacehorseCount[msg.sender] = ownerRacehorseCount[msg.sender].sub(1);
    racehorseToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    _transfer(msg.sender, _to, _tokenId);
  }

  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    racehorseApprovals[_tokenId] = _to;
    emit Approval(msg.sender, _to, _tokenId);
  }

  function takeOwnership(uint256 _tokenId) public {
    require(racehorseApprovals[_tokenId] == msg.sender);
    address owner = ownerOf(_tokenId);
    _transfer(owner, msg.sender, _tokenId);
  }
}
