// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

contract GameStorage {
    struct GameState {
        uint32 startTime;
        uint32 duration;
        uint96 entryFee;
        uint8 flags;
        uint88 reserved; // For future use, maintains slot packing
    }
    
    struct Player {
        uint32 lastInteractionTime;
        uint8 interactionCount;
        uint32 score;
        bytes32 username;
        bytes32 pseudonym;
        uint8 flags;
        uint40 reserved; // For future use, maintains slot packing
    }
    
    GameState internal _gameState;
    mapping(address => Player) internal _players;
    address[] internal _playerList;
    
    // Events
    event GameAction(uint8 indexed actionType, uint32 timestamp);
    event PlayerAction(
        address indexed player, 
        uint8 actionType, 
        uint32 score
    );
}
