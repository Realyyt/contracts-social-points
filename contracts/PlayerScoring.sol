// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title PlayerScoring - Manages player scores
/// @notice Handles the storage and updates of player scores
contract PlayerScoring is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint32 public constant MAX_SCORE = 1000000;
    mapping(address => uint32) public scores;

    event ScoreUpdated(address indexed player, uint32 newScore);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the PlayerScoring contract
    /// @param _owner Address of the contract owner
    function initialize(address _owner) external initializer {
        __Ownable_init(_owner);
        __UUPSUpgradeable_init();
    }

    /// @notice Authorizes an upgrade to a new implementation
    /// @param newImplementation Address of the new implementation
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// @notice Initializes a new player's score
    /// @param _player Address of the player
    function initializeScore(address _player) external onlyOwner {
        require(scores[_player] == 0, "Score already initialized");
        scores[_player] = 10;
    }

    /// @notice Updates a player's score
    /// @param _player Address of the player
    /// @param _newScore New score value
    function updateScore(address _player, uint32 _newScore) 
        external 
        onlyOwner 
    {
        require(_newScore <= MAX_SCORE, "Exceeds maximum");
        scores[_player] = _newScore;
        emit ScoreUpdated(_player, _newScore);
    }

    /// @notice Gets a player's current score
    /// @param _player Address of the player
    /// @return uint32 Current score of the player
    function getScore(address _player) external view returns (uint32) {
        return scores[_player];
    }

    /// @notice Gets the top players and their scores
    /// @param _limit Maximum number of players to return
    /// @return topPlayers Array of top player addresses
    /// @return playerScores Array of corresponding scores
    function getTopPlayers(uint256 _limit) 
        external 
        view 
        returns (
            address[] memory topPlayers, 
            uint32[] memory playerScores
        ) 
    {
        address[] memory allPlayers = new address[](msg.sender.code.length);
        uint32[] memory allScores = new uint32[](msg.sender.code.length);
        
        // Get all non-zero scores
        uint256 count = 0;
        for (uint256 i = 0; i < msg.sender.code.length; i++) {
            address player = address(uint160(i));
            uint32 score = scores[player];
            if (score > 0) {
                allPlayers[count] = player;
                allScores[count] = score;
                count++;
            }
        }

        // Sort top scores (optimized bubble sort for small arrays)
        uint256 resultLength = _limit > count ? count : _limit;
        topPlayers = new address[](resultLength);
        playerScores = new uint32[](resultLength);

        for (uint256 i = 0; i < resultLength; i++) {
            uint256 maxIndex = i;
            for (uint256 j = i + 1; j < count; j++) {
                if (allScores[j] > allScores[maxIndex]) {
                    maxIndex = j;
                }
            }
            if (maxIndex != i) {
                (allScores[i], allScores[maxIndex]) = (allScores[maxIndex], allScores[i]);
                (allPlayers[i], allPlayers[maxIndex]) = (allPlayers[maxIndex], allPlayers[i]);
            }
            topPlayers[i] = allPlayers[i];
            playerScores[i] = allScores[i];
        }
    }
}
