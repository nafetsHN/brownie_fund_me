// SPDX=License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    uint256 public max_nft_count = 4;
    uint256 public nft_number = 0;
    uint256 minimumUSD = 50 * 10**18; // $50;

    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        // everything inside constructor gets called instantly when
        // contract FundMe is created
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    modifier onlyOwner() {
        // do this before rest of the code
        require(msg.sender == owner);
        // dp rest of the code instead of _;
        _;
    }

    modifier limitNFT() {
        // check if max_nft_count is reached and
        // stop any futher funding
        require(nft_number < max_nft_count, "Max number of NFTs reached!");
        _;
    }

    modifier incrementNFT() {
        _;
        // add one NFT to the nft_number
        nft_number += 1;
    }

    modifier floorTransactionValue() {
        // revert transaction if msg.value is below minimumUSD
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more ETH!"
        );
        _;
    }

    function fund() public payable limitNFT floorTransactionValue incrementNFT {
        // add transaction sender and value to mapp
        addressToAmountFunded[msg.sender] += msg.value;

        // list all funders in array
        funders.push(msg.sender);
    }

    // send all ETH available in contract to owner of the contract only
    function withdraw() public payable onlyOwner {
        // only accepts contract adming/owner transfers
        msg.sender.transfer(address(this).balance);

        // set funders balance to zero after withdrawal
        for (
            uint256 fundersIndex = 0;
            fundersIndex < funders.length;
            fundersIndex++
        ) {
            address funder = funders[fundersIndex];
            addressToAmountFunded[funder] = 0;
        }

        // reset funders array
        funders = new address[](0);
    }

    function getEntranceFee() public view returns (uint256) {
        //minimumUSD
        uint256 minimumUSD = 50 * 1 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    function getVersion() public view returns (uint256) {
        // Hardcode address -> Rinkeby
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        //);
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // Hardcode address -> Rinkeby
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //    0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function getDescription() public view returns (string memory) {
        // Hardcode address -> Rinkeby
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );
        return priceFeed.description();
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // 5802.689750560000000000
        return ethAmountInUsd;
    }
}
