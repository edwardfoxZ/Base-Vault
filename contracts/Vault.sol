// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {
    // Admin address
    address public owner;

    // Token
    IERC20 public token;

    // Token price per wei
    uint256 public pricePerTokenWei = 1e11;

    uint256 public unlockPrice;

    /**
     * @dev Buyer tracking
     * buyer,amountBought,timestamp,amountUnlocked
     */
    struct BuyerInfo {
        address buyer;
        uint256 amountBought;
        uint256 timestamp;
        uint256 amountUnlocked;
    }

    BuyerInfo[] public buyers;
    mapping(address => uint256) public totalBought;
    mapping(address => uint256) public totalUnlocked;
    mapping(address => bool) public alreadyAdded;

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    /**
     * @dev Allows the owner to fund the contract with tokens.
     */
    function fund(uint256 _fundAmount) external onlyOwner {
        bool success = token.transferFrom(
            msg.sender,
            address(this),
            _fundAmount
        );
        require(success, "Failed to fund the contract");
    }

    /**
     * @dev User can buy the tokens from here.
     */
    function buy() external payable {
        require(msg.value > 0, "Send enough ETH");

        uint256 tokensToBuy = (msg.value * 1e18) / pricePerTokenWei;
        require(tokensToBuy > 0, "Zero tokens");

        if (!alreadyAdded[msg.sender]) {
            buyers.push(
                BuyerInfo({
                    buyer: msg.sender,
                    amountBought: tokensToBuy,
                    timestamp: block.timestamp,
                    amountUnlocked: 0
                })
            );
            alreadyAdded[msg.sender] = true;
        } else {
            for (uint256 i = 0; i < buyers.length; i++) {
                if (buyers[i].buyer == msg.sender) {
                    buyers[i].amountBought += tokensToBuy;
                }
            }
        }

        totalBought[msg.sender] += tokensToBuy;
        emit TokenPurchased(msg.sender, tokensToBuy, block.timestamp);
    }

    /**
     * @dev If user hasn't received tokens yet, they can claim first.
     */
    function claim() external {
        bool isEligible = false;
        require(totalBought[msg.sender] > 0, "Not enough token");

        for (uint256 i = 0; i < buyers.length; i++) {
            if (buyers[i].buyer == msg.sender && buyers.length <= 1000) {
                isEligible = true;
            } else {
                isEligible = false;
            }
        }

        require(isEligible, "You are not eligible");

        uint256 claimable = getClaimableAmount(msg.sender);
        require(claimable > 0, "No tokens unlocked to claim");

        totalUnlocked[msg.sender] += claimable;

        require(token.transfer(msg.sender, claimable), "Token transfer failed");

        emit TokenClaimed(msg.sender, claimable, block.timestamp);
    }

    function setUnlockPrice(uint256 _newPrice) external onlyOwner {
        unlockPrice = _newPrice;
    }

    // Admin: withdraw ETH
    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getClaimableAmount(address _user) public view returns (uint256) {
        if (totalUnlocked[_user] >= totalBought[_user]) {
            return 0;
        }

        uint256 remaining = totalBought[_user] - totalUnlocked[_user];
        uint256 unlockPerClaim = 500 * 1e18;

        if (remaining >= unlockPerClaim) {
            return unlockPerClaim;
        } else {
            return remaining;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Events
    event TokenPurchased(
        address indexed buyer,
        uint256 amountToBuy,
        uint256 timestamp
    );

    event TokenClaimed(
        address indexed buyer,
        uint256 amountToClaim,
        uint256 timestamp
    );
}
