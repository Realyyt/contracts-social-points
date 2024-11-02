// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title PointsRules - Defines rules for point calculations
/// @notice Contains the logic for calculating points in various game scenarios
contract PointsRules is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint8 public interactionPoints;
    uint8 public meetupPoints;
    uint8 public pointsPerTenHours;
    uint32 public maxScore;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the PointsRules contract
    /// @param _owner Address of the contract owner
    function initialize(address _owner) external initializer {
        __Ownable_init(_owner);
        __UUPSUpgradeable_init();
        interactionPoints = 2;
        meetupPoints = 4;
        pointsPerTenHours = 1;
        maxScore = 1000000;
    }

    /// @notice Authorizes an upgrade to a new implementation
    /// @param newImplementation Address of the new implementation
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// @notice Calculates points for player interaction
    /// @param score1 Score of first player
    /// @param score2 Score of second player
    /// @return uint32 New score for first player
    /// @return uint32 New score for second player
    function calculateInteraction(uint32 score1, uint32 score2) 
        external 
        view 
        returns (uint32, uint32) 
    {
        if (score1 > score2) {
            return (
                score1 + interactionPoints,
                score2 > interactionPoints ? score2 - interactionPoints : 0
            );
        } else {
            return (
                score1 > interactionPoints ? score1 - interactionPoints : 0,
                score2 + interactionPoints
            );
        }
    }

    /// @notice Calculates points for meetup attendance
    /// @param currentScore Current score of the player
    /// @return uint32 New score after meetup
    function calculateMeetup(uint32 currentScore) 
        external 
        view 
        returns (uint32) 
    {
        uint32 newScore = currentScore + meetupPoints;
        require(newScore >= currentScore, "Score overflow");
        return newScore;
    }

    /// @notice Calculates points accrued over time
    /// @param currentScore Current score of the player
    /// @param lastAccrualTime Last time points were accrued
    /// @param currentTime Current timestamp
    /// @return uint32 New score after accrual
    function calculateAccrued(
        uint32 currentScore,
        uint32 lastAccrualTime,
        uint32 currentTime
    ) 
        external 
        view 
        returns (uint32) 
    {
        uint32 tenHoursPassed = (currentTime - lastAccrualTime) / 36000;
        uint32 pointsToAdd = tenHoursPassed * pointsPerTenHours;
        uint32 newScore = currentScore + pointsToAdd;
        require(newScore >= currentScore && newScore <= maxScore, "Invalid score");
        return newScore;
    }
}
