// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./PlayerManager.sol";
import "./PointsRules.sol";

/// @title PointsCalculator - Calculates points for player interactions
/// @notice Handles all point calculations for player interactions and activities
contract PointsCalculator is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    PlayerManager public playerManager;
    PointsRules public pointsRules;

    event PointsCalculated(address indexed player, uint32 newScore);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the PointsCalculator contract
    /// @param _playerManager Address of the PlayerManager contract
    /// @param _pointsRules Address of the PointsRules contract
    /// @param _owner Address of the contract owner
    function initialize(
        address _playerManager,
        address _pointsRules,
        address _owner
    ) external initializer {
        __Ownable_init(_owner);
        __UUPSUpgradeable_init();
        playerManager = PlayerManager(_playerManager);
        pointsRules = PointsRules(_pointsRules);
    }

    /// @notice Authorizes an upgrade to a new implementation
    /// @param newImplementation Address of the new implementation
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// @notice Calculates points for player interaction
    /// @param _player1 Address of the first player
    /// @param _player2 Address of the second player
    function calculateInteractionPoints(address _player1, address _player2) 
        external 
        onlyOwner 
    {
        (uint32 score1,,,) = playerManager.getPlayer(_player1);
        (uint32 score2,,,) = playerManager.getPlayer(_player2);
        (uint32 newScore1, uint32 newScore2) = pointsRules.calculateInteraction(
            score1,
            score2
        );

        playerManager.updateScore(_player1, newScore1);
        playerManager.updateScore(_player2, newScore2);
        
        emit PointsCalculated(_player1, newScore1);
        emit PointsCalculated(_player2, newScore2);
    }

    /// @notice Calculates points for meetup attendance
    /// @param _player Address of the player
    function calculateMeetupPoints(address _player) 
        external 
        onlyOwner 
    {
        (uint32 currentScore,,,) = playerManager.getPlayer(_player);
        uint32 newScore = pointsRules.calculateMeetup(currentScore);
        
        playerManager.updateScore(_player, newScore);
        emit PointsCalculated(_player, newScore);
    }

    /// @notice Calculates accrued points over time
    /// @param _player Address of the player
    function calculateAccruedPoints(address _player) 
        external 
        onlyOwner 
    {
        (uint32 score, uint32 lastPointAccrualTime,,) = playerManager.getPlayer(_player);
        
        uint32 newScore = pointsRules.calculateAccrued(
            score,
            lastPointAccrualTime,
            uint32(block.timestamp)
        );
        
        playerManager.updateScore(_player, newScore);
        emit PointsCalculated(_player, newScore);
    }
}
