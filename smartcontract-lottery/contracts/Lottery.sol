// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable{
    // Keep track of all the players
    address payable[] public players;
    address payable public recentWinner;
    uint256 randomness;
    // Define the constant value of the entry fee
    uint256 public usdEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;
    uint256 fee;
    bytes32 keyhash;

    // Constructor
    constructor(address _priceFeedAddress, address _vrfCoordinator, address _link, uint256 _fee, bytes32 _keyhash) public VRFConsumerBase(_vrfCoordinator, _link) {
        usdEntryFee = 50 * (10**18);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
        fee = _fee;
        keyhash = _keyhash;
    }

    function enter() public payable {
        // Only enter if the lottery has been started
        require(lottery_state == LOTTERY_STATE.OPEN);
        // Minimum entry fee is 50USD
        require(
            msg.value >= getEntranceFee(),
            "Entry fee has to be 50 USD or more"
        );
        players.push(msg.sender);
    }

    // Gets the entrance fee
    function getEntranceFee() public view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();

        //
        uint256 adjustedPrice = uint256(price) * 10**10; // convert to 18 decimals as the chainlink usd-eth pricefeed is provided in 8 decimal places. See docs;
        uint256 costToEnter = (usdEntryFee * 10**18) / adjustedPrice; //raise to 18  decimals so the decimals cancels out
        return costToEnter;
    }

    function startLottery() public onlyOwner{
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Cannot start a new lottery yet!"
        );

        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLotter() public onlyOwner{
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;

        requestRandomness(keyhash, fee); // from the inherited VRFConsumerBase class 
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)internal override{
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER, "You aren't there yet");
        require(_randomness > 0, "random-not-found");

        uint256 indexOfWinner = _randomness % players.length;
        recentWinner = players[indexOfWinner];
        recentWinner.transfer(address(this).balance);
        // reset
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
        randomness = _randomness;
    }
}
