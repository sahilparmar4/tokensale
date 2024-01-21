// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 < 0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyToken is ERC20{
    using SafeMath for uint256;
    uint lockedTime = 2 minutes;
    address public owner = _msgSender();
    uint maximumLimit = 10000;
    mapping(address => uint256) public purchasedTokens;
    uint public constant tokenPrice= 3 ether;
    mapping (address=>uint256) public balances;
    mapping (address =>uint256) public tokenClaimed;
    mapping(address=>uint256) public tokenPurchased;
    uint public tokenValue;

    constructor(uint256 _totalSupply) ERC20("MyERC20Token", "ME20T"){
        _mint(address(this), _totalSupply);
    }

    function purchaseRequest(address _user, uint256 _numberOfTokens) public payable  {
        require(_numberOfTokens > 0, "numberOfTokens should be grater than zero");
        require(_numberOfTokens.add(purchasedTokens[msg.sender]) <= maximumLimit, "You cannot buy more than 10000 tokens");
        uint256 cost = _numberOfTokens * tokenPrice;
        require(balanceOf(address(this))>=_numberOfTokens, "Contract has not enough tokens");
        require(msg.value == cost, "Insufficient Ether sent");
        _approve(address(this), _user, _numberOfTokens);
        transferFrom(address(this), _user, _numberOfTokens);
        tokenPurchased[_user] +=_numberOfTokens;
        tokenClaimed[_user] = block.timestamp + lockedTime;
    }

    function getUserDetails(address _user) public view returns (uint, uint){
        return (balanceOf(_user), tokenClaimed[_user]);
    }

    function claimTokens() public {
        require(block.timestamp > tokenClaimed[msg.sender], "Wait");
        transfer(msg.sender, tokenPurchased[msg.sender]);
    }

}