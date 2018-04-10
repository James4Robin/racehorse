# Racehorse Smart Contracts
The project contains:

1) Racehorse and Racetrack Contracts
2) Racehorse Smart Contracts for Games

Current status as of 04/2018 is that The contract has basically been completed and finalized.
Racehorse Smart Contracts is still debugging and improving.We still want to add some unique ideas to go in and make it look more interesting and appealing.

About the game content:
1) This is a game of bred animals. It is your pet, partner and friend. A majestic racehorse.
2) You will take care of it and make it grow.
3) You will want your racehorse to contact its racehorse and come to a friendly match.

All contracts are properly documented, and main information for their usage can be found in the source code documentation.

## Racehorse and Racetrack Contracts


### RacehorseFactory
Here we define all the attributes that a horse needs.
```
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
```
We hope that such a definition can maximize the cost savings for users.
Agile(dex), strong, and adaptability are the three attributes that are used to control the game.
Color, mane, eyes are random attributes.Sometimes we don't write all random properties to dna. So we may be able to control them more flexibly.

Random number generation via keccak256
The best source of randomness we have in Solidity is the keccak256 hash function.

We could do something like the following to generate a random number:
```
uint randNonce = 0;
function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(now, msg.sender, randNonce)) % _modulus;
  }
```
"randMod" is a very important method. We will use it more than once in the future.

What this would do is take the timestamp of now, the msg.sender, and an incrementing nonce (a number that is only ever used once, so we don't run the same hash function with the same input parameters twice).

It would then use keccak to convert these inputs to a random hash, convert that hash to a uint, and then use % _modulus to  giving us a totally random number between 0 and _modulus.

Of course, we understand that this method is not absolutely safe.

Since tens of thousands of Ethereum nodes on the network are competing to solve the next block, my odds of solving the next block are extremely low. It would take me a lot of time or computing resources to exploit this profitably — but if the re
d were high enough (like if I could bet $100,000,000 on the coin flip function), it would be worth it for me to attack.

So while this random number generation is NOT secure on Ethereum, in practice unless our random function has a lot of money on the line, the users of your game likely won't have enough resources to attack it.

We use it for the time being to complete the request for random numbers.

In "_createRacehorse" we initialize a horse, set some initial values and set some random values.
```
    uint8 colorNum = uint8(randMod(16));
    uint8 maneNum = uint8(randMod(16));
    uint8 eyesNum = uint8(randMod(16));
    uint id = racehorses.push(Racehorse(_name, _dna, 1, uint32(now + feedCooldownTime), 5, 5, 1, 0, 0, colorNum, maneNum, eyesNum)) - 1;
```
Of course, this method is internal. User needs to call another method "createRandomRacehorse".
In method "createRandomRacehorse", we will judge the users, only those users who do not have a racehorse can complete the initialization racehorse.

Sources are located in [racehorsefactory.sol](contracts/racehorsefactory.sol).

### RacetrackFactory

The reason why RacetrackFactory inherits RacehorseFactory is mainly like using RacehorseFactory's "randMod" method.

```
  struct Racetrack {
    string name;
    string condition;
    uint8 degree;
  }
```
We defined some attributes of the racetrack. 
"degree" represents the degree of difficulty of this racetrack.We will use it to calculate the outcome of the game.
"condition" means that in the course of the match, which attributes of the horse will be the most critical factor, "dex", "str", or "ada".
"createRacetrack" This method, we limit it can only be called by the owner of the contract.

Sources are located in [racetrackfactory.sol](contracts/racetrackfactory.sol).

## Racehorse Smart Contracts for Games


### RacehorseGrow

We have completed a method to judge the owner of the racehorse. After all, no one wants to own a racehorse, others can control it.
```
   modifier onlyOwnerOf(uint _racehorseId) {
    require(msg.sender == racehorseToOwner[_racehorseId]);
    _;
  }
```
Before some instructions for racehorse are executed, they are authenticated with "onlyOwnerOf".

We provide an interface for users to keep your racehorse. The racehorse can be acquired by the user and each time some experience value is acquired.

When the experience value is accumulated to 100, it will be converted into a skill point.

Ultimately, users use these skill points to change the racehorse attributes and upgrade them.

This is a game of bred animals. You will take care of it and make it grow. We defined it this way. Now we have realized it.

In addition, we have added a cooling system. You can feed a horse for at least 6 hours. Only in this way can there be a more real sense of experience.

Considering that each time the user uses the skill points to make adjustments to the racehorse properties, we provide a method that allows the user to adjust the racehorse at a time by consuming multiple skill points.

Of course, the premise is that users do have enough skill points to make adjustments.

Sources are located in [racehorsegrow.sol](contracts/racehorsegrow.sol).

### RacehorseHelper

In this contract, we have completed the check of the grade. Later, at different levels, it may be possible to develop a number of different functions to command racehorse.

In this way, users may be more motivated to keep their pets in order to unlock more gameplay.

At the same time, in this contract, we tried to complete the payment event. Just to test the payment function, it is not really necessary to open these functions. We do not want to undermine the fairness of the game.Please don't worry about this.

We provide ways to change the dna. The user can modify one bit of the dna by consuming skill points. After all, many games respond to different appearances through the dna. Some users may wish to make efforts to make their racing motors look like they like. In the use case, we only tried to modify the last digit and the penultimate digit. Currently this method is still in testing and updating.

```
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
```

Sources are located in [racehorsehelper.sol](contracts/racehorsehelper.sol).

### RacehorseOwnership

Let's talk about tokens.

ERC721 tokens are not interchangeable since each one is assumed to be unique, and are not divisible. You can only trade them in whole units, and each one has a unique ID. So these are a perfect fit for making our racehorse tradeable.

In this contract, we have completed some methods of transfer. In this way, the user's racehorse can be traded. RacehorseOwnership implements the ERC721 interface.

Sources are located in [racehorseownership.sol](contracts/racehorseownership.sol).

### RacehorseRacing

In the end, did a racehorse racing for a long time also want to compete with other racehorses? In this contract, we achieved this thing. This is a very cool thing.

```
function racing(uint _racehorseId, uint8 _cphorses) external aboveLevel(5, _racehorseId) onlyOwnerOf(_racehorseId) playersCheck(_cphorses)
```

First, the user can choose from 1 to 7 other racehorse races. Of course, the greater the number, the greater the difficulty of winning, but at the same time, the racehorse's earnings are also high.

After the user specifies the number, these horses have system selection. The screening conditions are very strict. It must be the same as the race attribute of the racehorse. We do not want a high-performance horse racing to go to a low-level horse race every day, and vice versa.

The racehorse attribute is a numerical synthesis of dex, str, and ada. 

In this scenario, the previously created racetrack will be used. The racetrack was randomly selected.

The result of the competition is directly related to the racetrack attributes. 

If the venue type is "str", then a racehorse with "str" high value will significantly increase the chance of winning.This type is determined by the racetrack.condition.

When the racetrack.condition is not str or dex, degree becomes the dominant value.

```
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
```

Is it better to train a high-speed(dex) racehorse, a high-strength(str) racehorse, or a more adaptable(ada) racehorse? This is a problem that the user needs to consider.

If you let me suggest, it might be better to analyze the data of all the venues before making a decision.

The reward for the game is very rich, as long as there is a skill point reward for the victory, and at the same time a level. Even if you lose the game you will get some experience. If you choose multiple opponents, you will receive multiple bonuses.

Sources are located in [racehorseracing.sol](contracts/racehorseracing.sol).
