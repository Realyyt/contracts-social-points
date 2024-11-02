// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./PlayerScoring.sol";

/// @title PlayerManager - Manages player registration and scoring
/// @notice Handles player registration, scoring, and ranking functionality
contract PlayerManager is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    struct Player {
        uint32 lastPointAccrualTime;
        bytes32 username;
        bytes32 pseudonym;
        uint32 score;  // Moved from separate contract
        uint8 flags;   // For boolean states
    }

    mapping(address => Player) public players;
    address[] public playerAddresses;
    PlayerScoring public playerScoring;

    event PlayerRegistered(address indexed player, bytes32 username);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the PlayerManager contract
    /// @param _owner Address of the contract owner
    /// @param _playerScoring Address of the PlayerScoring contract
    function initialize(address _owner, address _playerScoring) external initializer {
        __Ownable_init(_owner);
        __UUPSUpgradeable_init();
        playerScoring = PlayerScoring(_playerScoring);
    }

    /// @notice Authorizes an upgrade to a new implementation
    /// @param newImplementation Address of the new implementation
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// @notice Adds a new player to the game
    /// @param _player Address of the player to add
    /// @param _username Username of the player
    /// @param _pseudonym Pseudonym of the player
    function addPlayer(address _player, bytes32 _username, bytes32 _pseudonym) 
        external 
        onlyOwner 
    {
        require(players[_player].username == bytes32(0), "Already registered");
        require(_username != bytes32(0), "Invalid username");
        
        players[_player] = Player({
            lastPointAccrualTime: uint32(block.timestamp),
            username: _username,
            pseudonym: _pseudonym,
            score: 0,
            flags: 0
        });
        
        playerAddresses.push(_player);
        playerScoring.initializeScore(_player);
        emit PlayerRegistered(_player, _username);
    }

    /// @notice Retrieves player information
    /// @param _player Address of the player
    /// @return score Player's current score
    /// @return lastPointAccrualTime Last time points were accrued
    /// @return username Player's username
    /// @return pseudonym Player's pseudonym
    function getPlayer(address _player) 
        external 
        view 
        returns (
            uint32 score,
            uint32 lastPointAccrualTime,
            bytes32 username,
            bytes32 pseudonym
        ) 
    {
        Player memory player = players[_player];
        return (
            playerScoring.getScore(_player),
            player.lastPointAccrualTime,
            player.username,
            player.pseudonym
        );
    }

    /// @notice Gets the total number of registered players
    /// @return uint256 Number of players
    function getPlayerCount() external view returns (uint256) {
        return playerAddresses.length;
    }

    /// @notice Updates a player's score
    /// @param _player Address of the player
    /// @param _newScore New score to set
    function updateScore(address _player, uint32 _newScore) external onlyOwner {
        playerScoring.updateScore(_player, _newScore);
        players[_player].lastPointAccrualTime = uint32(block.timestamp);
    }

    /// @notice Gets the top players and their scores
    /// @return address[] Array of top player addresses
    /// @return uint32[] Array of corresponding scores
    function getTopPlayers() external view returns (address[] memory, uint32[] memory) {
        // Determine how many players to return (e.g., top 3)
        uint256 numWinners = 3;
        
        // Create arrays to store results
        address[] memory winners = new address[](numWinners);
        uint32[] memory scores = new uint32[](numWinners);
        
        // Initialize with minimum values
        for (uint256 i = 0; i < numWinners; i++) {
            winners[i] = address(0);
            scores[i] = 0;
        }
        
        // Iterate through all players to find top scores
        // Note: This is a basic implementation. For large numbers of players,
        // you might want to maintain a sorted list instead
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            (uint32 playerScore,,,) = this.getPlayer(playerAddresses[i]);
            
            // Check if this score should be in top N
            for (uint256 j = 0; j < numWinners; j++) {
                if (playerScore > scores[j]) {
                    // Shift lower scores down
                    for (uint256 k = numWinners - 1; k > j; k--) {
                        winners[k] = winners[k-1];
                        scores[k] = scores[k-1];
                    }
                    // Insert new high score
                    winners[j] = playerAddresses[i];
                    scores[j] = playerScore;
                    break;
                }
            }
        }
        
        return (winners, scores);
    }
}
