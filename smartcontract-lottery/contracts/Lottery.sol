// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract Lottery {
    // Keep track of all the players
    address payable[] public players;
    // Define the constant value of the entry fee
    uint256 public usdEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;

    // Constructor
    constructor(address _priceFeedAddress) public {
        usdEntryFee = 50 * (10**18);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function enter() public payable {
        // Minimum entry fee is 50USD
        require(msg.value >= 50, "Entry fee has to be 50 USD or more");
        players.push(msg.sender);
    }

    // Gets the entrance fee
    function getEntranceFee() public view returns (uint256) {
        (, int256 price, , , , ) = ethUsdPriceFeed.latestRoundData;

        //
        uint256 adjustedPrice = uint256(price) * 10**10; // convert to 18 decimals as the chainlink usd-eth pricefeed is provided in 8 decimal places. See docs;
        uint256 costToEnter = (usdEntryFee * 10**18) / price; //raise to 18  decimals so the decimals cancels out
        return costToEnter;
    }

    function startLottery() public {}

    function endLotter() public {}
}
