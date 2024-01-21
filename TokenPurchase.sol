// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";


contract MyToken is ERC20,ERC20Permit {


    uint256 public constant TOKEN_PRICE = 2 ether;

    uint256 public constant MAX_TOKENS_PER_PURCHASE = 100;

    uint256 public constant ACCESS_WAIT_PERIOD = 2 minutes;

    uint256 public constant TOKEN_LOCK_DURATION = 2 minutes;


    mapping(address => uint256) public purchaseTimestamps;

    mapping(address => uint256) public tokensPurchased;

    mapping(address => mapping(uint256 => uint256)) public tokenReleaseTimestamps;


    constructor(string memory name, string memory symbol,uint256 initialSupply) ERC20(name, symbol) ERC20Permit(name){

    	_mint(address(this),initialSupply );
    
    }


    function purchaseTokens(uint256 numberOfTokens) external payable {

            require(numberOfTokens > 0, "Number of tokens must be greater than 0");

            require(numberOfTokens <= MAX_TOKENS_PER_PURCHASE, "Exceeds maximum tokens per purchase");

            require(msg.value == numberOfTokens * TOKEN_PRICE, "Incorrect payment amount! amout is 2 ether per token");


            // Check if the user has waited for the required period since the last purchase

            require(block.timestamp >= purchaseTimestamps[msg.sender] + ACCESS_WAIT_PERIOD, "Access not yet granted");


            // Update the purchase timestamp for the user

            purchaseTimestamps[msg.sender] = block.timestamp;


            // Check if the user has already purchased tokens
 
            require(tokensPurchased[msg.sender] + numberOfTokens <= MAX_TOKENS_PER_PURCHASE, "Exceeds maximum total tokens purchased");


            // Update the total tokens purchased by the user

            tokensPurchased[msg.sender] += numberOfTokens;


            // Set release timestamps for the purchased tokens

            for (uint256 i = 0; i < numberOfTokens; i++) {

                tokenReleaseTimestamps[msg.sender][tokensPurchased[msg.sender] - i] = block.timestamp + TOKEN_LOCK_DURATION;

            }


            // Transfer tokens from the contract to the buyer

            _transfer(address(this), msg.sender, numberOfTokens);

     }


     function claimTokens(uint256 tokenId) external {

            // Check if the release timestamp has passed

            require(block.timestamp >= tokenReleaseTimestamps[msg.sender][tokenId], "Tokens not yet claimable");


            // Transfer tokens from the buyer to the buyer's account

            _transfer(msg.sender, msg.sender, 1);

      }


}