// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "./PrizeStorage.sol";

/// @title PrizeDistributor - Handles prize distribution
/// @notice Manages the distribution of prizes to winners
contract PrizeDistributor is 
    Initializable, 
    OwnableUpgradeable, 
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable 
{
    PrizeStorage public prizeStorage;

    event PrizeDistributorInitialized();
    event PrizesCalculated(address[] winners, uint256[] prizes);
    event PrizeClaimed(address indexed winner, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the PrizeDistributor contract
    /// @param _owner Address of the contract owner
    /// @param _prizeStorage Address of the PrizeStorage contract
    function initialize(address _owner, address _prizeStorage) external initializer {
        __Ownable_init(_owner);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        prizeStorage = PrizeStorage(_prizeStorage);
        emit PrizeDistributorInitialized();
    }

    /// @notice Authorizes an upgrade to a new implementation
    /// @param newImplementation Address of the new implementation
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// @notice Distributes prizes to winners
    /// @param _winners Array of winner addresses
    /// @param _scores Array of winner scores
    function distributePrizes(
        address[] memory _winners, 
        uint32[] memory _scores
    ) external onlyOwner whenNotPaused {
        require(_winners.length == _scores.length, "Mismatched arrays");
        require(_winners.length > 0, "No winners");
        
        for (uint256 i = 1; i < _scores.length; i++) {
            require(_scores[i-1] >= _scores[i], "Scores not sorted");
        }
        
        uint256 totalPrizePool = address(this).balance;
        require(totalPrizePool > 0, "No prizes to distribute");

        uint8 winnersCount = uint8(_winners.length > 10 ? 10 : _winners.length);
        uint256[] memory prizes = new uint256[](winnersCount);

        for (uint8 i = 0; i < winnersCount; i++) {
            uint256 prize = (totalPrizePool * prizeStorage.getPrizePercentage(i)) / 100;
            prizeStorage.setPendingPrize(_winners[i], prize);
            prizes[i] = prize;
        }

        emit PrizesCalculated(_winners, prizes);
    }

    /// @notice Allows winners to claim their prizes
    function claimPrize() external nonReentrant whenNotPaused {
        uint256 prize = prizeStorage.getPendingPrize(msg.sender);
        require(prize > 0, "No prize to claim");
        
        prizeStorage.clearPendingPrize(msg.sender);
        
        (bool success, ) = msg.sender.call{value: prize}("");
        require(success, "Transfer failed");
        
        emit PrizeClaimed(msg.sender, prize);
    }

    /// @notice Pauses the contract
    function pause() external onlyOwner { _pause(); }

    /// @notice Unpauses the contract
    function unpause() external onlyOwner { _unpause(); }
    
    receive() external payable {
        prizeStorage.updateTotalPrizePool(address(this).balance);
    }

    /// @notice Withdraws remaining balance to owner
    function withdrawRemainingBalance() external onlyOwner nonReentrant {
        uint256 remainingBalance = address(this).balance;
        require(remainingBalance > 0, "No balance");
        (bool success, ) = owner().call{value: remainingBalance}("");
        require(success, "Transfer failed");
    }
}
