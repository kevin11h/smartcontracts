pragma solidity ^0.4.24;

contract baseModifiers {
    address public owner;
    bool activated_;
    modifier isActivated() {
        require(activated_ == true, "its not ready yet"); 
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function activateContract() onlyOwner {
        activated_ = true;
    }

    function deactivateContract() onlyOwner {
        activated_ = false;
    }

    function constructor() {
        owner = msg.sender;
    }
}

//send librarys and api proposal
//use truffle
contract whiteListContractsAndBaseModifiers is baseModifiers {
    mapping (address => bool) public whiteListedContracts;

    function addContractAddress(address _contractAddress) onlyOwner external {
        whiteListedContracts[_contractAddress]=true;
    }

    function removeContractAddress(address _contractAddress) onlyOwner external {
        require (_contractAddress != 0);
        require (whiteListedContracts[_contractAddress] != false);
        delete(whiteListedContracts[_contractAddress]);
    }

    modifier isHumanOrWhitelistedContract() {
        address _addr = msg.sender;
        if (whiteListedContracts[_addr]==false) {
            require (_addr == tx.origin);
            uint256 _codeLength;
            assembly {_codeLength := extcodesize(_addr)}
            require(_codeLength == 0, "sorry humans only");
        }
        _;
    }

    function constructor() {
    }
}

contract beeArbEvents {

    // fired whenever an aribitration is requested
    event onArbitrationRequested
    (
        uint256 arbitrationId, //the unique id of the arbitration requested
        bytes32 reservationId, //listing ids are byte32s, reservation id might be different
        uint256 timeStamp, //timestamp of request
        uint256 minTime, //min timetimestamp to wait for when miners can start to try and arbitrate
        uint256 maxTime, //maximum timestamp to wait until before defaulting to default arbitrators
        uint256 beeTokensDispute, //amount of bee tokens in dispute
        uint256 beeTokensArbitration //amount of bee tokens paid for arbitration to occur
    );
    
    // fired when not enough miners are present to start arbitration process
    event onNotEnoughMinMiners
    (
        uint256 arbitrationId, //the unique id of the arbitration requested
        bytes32 reservationId, //listing ids are byte32s, reservation id might be different
        uint256 timeStamp //timestamp
    );
    
	// fired when a miner has completed a vote
    event onArbitrationVoteRecived
    (
        uint256 arbitrationId, //the unique id of the arbitration requested
        uint256 arbitorId, //the id of the arbitor who voted 
        bytes32 reservationId, //listing ids are byte32s, reservation id might be different
        uint256 timeStamp //timestamp of vote
    );
    
    // fired when an arbitraion is completed
    event onArbitrationCompleted
    (
        uint256 arbitrationId, //the unique id of the arbitration requested
        //maybe put in who voted for what in here too?
        uint8 voteResult, //temp value, could put in percent 0 - 100 awarded
        bytes32 reservationId, //listing ids are byte32s, reservation id might be different
        uint256 timeStamp //timestamp of vote
    );
    
    // fired when an arbitration appeal is submitted, could be wrapped up into arbitration submitted
    event onArbitrationAppealSubmitted
    (
        uint256 originalArbitrationId, //the unique id of the arbitration that is being appealed
        uint256 arbitrationId, //the unique id of the arbitration requested
        bytes32 reservationId, //listing ids are byte32s, reservation id might be different
        uint256 timeStamp, //timestamp of request
        uint256 minTime, //min timetimestamp to wait for when miners can start to try and arbitrate
        uint256 maxTime, //maximum timestamp to wait until before defaulting to default arbitrators
        uint256 beeTokensDispute, //amount of bee tokens in dispute
        uint256 beeTokensArbitration //amount of bee tokens paid for arbitration to occur
    );
    
    function constructor() {
    }
}


contract beeArbitration is beeArbEvents, whiteListContractsAndBaseModifiers {

    using SafeMath for uint256;

    uint256 minTimeWait = 1 days; //min time to wait before miners can be selected as arbitors
    uint256 maxTimeWait = 5 days; //max time to wait before going to default arbitors
    mapping (address => bool) defaultArbitors;   // arbitors that can make a ruling by themselves after max time on an abitration request

    uint256 arbitorVoteTime = 1 days; //max amount of time an arbitor has to vote before being penalized
    uint8 beeTokenPenality; //0-100% pentality for arbitors's staked bee tokens if submission isn't completed by max time


    //assumption: this contract cannot be run by another contract, otherwise true random is needed every time
    uint256 randThreshold; // true random is expensive, using random that a miner can manipulate by not completing a mine unless number of bee tokens submitted for bee token arbitration is above this threshold
    mapping (uint256 => mapping (address => uint256)) minerRandNumber;   // a random number a miner picks for true randomness, must be in same block to work


    /**
     * @dev default function, unsure about this at the moment, maybe disable
     *  -functionhash- unknown yet
     * @param none
     */
    function()
        public
    {
    }
    
    function constructor() 
    public 
    {
    }


    /**
     * @dev 
     *  -functionhash- unknown yet
     * @param none
     */
    function requestArbitration(uint256 reservationId)
        public
        isHumanOrWhitelistedContract()
    {
        //check to see if arbitration fee is enough 
        //put into arbitration queue
        //launch event telling everyone something is successfully in queue
    }
    
    /**
     * @dev preferabilly this is called when something is in the queue, 
     *      if not, a miner should not call this as it costs gas
     *  -functionhash- unknown yet
     * @param none
     */
    function startMining()
        public
        isHumanOrWhitelistedContract()
    {
        //check to see if user has a miner id, if not, create miner and assign id
        //put miner into mining queue
        //call trigger mining
    }

    /**
     * @dev 
     *  -functionhash- unknown yet
     * @param none
     */
    function stopMining()
        public
        isHumanOrWhitelistedContract()
    {
    }
    
    /**
     * @dev 
     *  -functionhash- unknown yet
     * @param none
     */
    function triggerMining()
        public
        isHumanOrWhitelistedContract()
    {
        //check to see if anything in the arbitration queue is ready to choose miners
        //check to see if there are at least x (5) miners in the mining queue
        //if there is enough miners, choose random number generator to generate random number
        //use random number generator to choose miners and assign them to vote 
    }
    
    


}

/**
 * @title FlagMask8
 * @dev Library implemented for FlagMasks.Flags (single byte).  Allows for 
 *      maximum usage of memory while providing good readability.
 *      Author: Arjay Waran
 */

library FlagMasks {
  struct Flags {
    bytes1 flagData;
  }
  
  function resetMasksOn(Flags memory flags) internal pure{
    flags.flagData = 0xFF;
  }

  function resetMasksOff(Flags memory flags) internal pure{
    flags.flagData = 0x00;  
  }

  function getFlag(Flags memory flags, uint index) internal pure returns (bool) {
    require(index<8);
    bytes1 flagMask = (bytes1)(2**index);
    if ((flags.flagData&flagMask) == 0) {
      return false;
    } else {
      return true;
    }
  }

  function setFlag(Flags memory flags, uint index, bool value) internal pure returns (Flags) { //returns byte32 for getto chaining
    require(index<8);
    bytes1 flagMask;
    if (value == true) {
        flagMask = (bytes1)(2**index);
        flags.flagData = flags.flagData|flagMask;
    } else {
        flagMask = (bytes1)(2**index) ^ 0xFF;
        flags.flagData = flags.flagData&flagMask;
    }
    return flags;
  }

}
/**
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr 
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 */
library SafeMath {
    
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
    /**
     * @dev x to the power of y 
     */
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}
