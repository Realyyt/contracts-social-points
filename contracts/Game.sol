// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "./storage/GameStorage.sol";
import "./libraries/GameLibrary.sol";
import "./libraries/GameTypes.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Game is GameStorage, UUPSUpgradeable, OwnableUpgradeable {
    using GameLibrary for uint32;
    
    using GameTypes for uint32;
    
    modifier whenActive() {
        if (!GameLibrary.hasFlag(_gameState.flags, GameLibrary.FLAG_ACTIVE))
            revert GameTypes.InvalidState();
        _;
    }
    
    function initialize(
        uint32 duration,
        uint96 entryFee,
        address owner
    ) external initializer {
        _gameState.duration = duration;
        _gameState.entryFee = entryFee;
        _gameState.flags = GameLibrary.FLAG_ACTIVE;
        _transferOwnership(owner);
    }

    function register(
        bytes32 username, 
        bytes32 pseudonym
    ) external payable whenActive {
        if (msg.value != _gameState.entryFee) revert GameTypes.IncorrectEntryFee();
        if (_playerList.length >= type(uint16).max) revert GameTypes.PlayerLimit();
        
        _players[msg.sender] = Player({
            lastInteractionTime: uint32(block.timestamp),
            interactionCount: 0,
            score: 10,
            username: username,
            pseudonym: pseudonym,
            flags: 0,
            reserved: 0
        });
        
        _playerList.push(msg.sender);
        emit PlayerAction(msg.sender, 0, 10);
    }

    function interact(address player2) external whenActive {
        Player storage p1 = _players[msg.sender];
        Player storage p2 = _players[player2];
        
        if (!GameLibrary.canInteract(
            p1.lastInteractionTime,
            p1.interactionCount,
            GameLibrary.MAX_DAILY_INTERACTIONS
        )) revert GameTypes.InvalidInteraction();
        
        (uint32 newScore1, uint32 newScore2) = GameLibrary.calculatePoints(
            p1.score,
            p2.score
        );
        
        if (newScore1 > GameLibrary.MAX_SCORE || 
            newScore2 > GameLibrary.MAX_SCORE) revert GameTypes.ScoreOverflow();
            
        (p1.lastInteractionTime, p1.interactionCount) = GameLibrary.updateInteraction(
            p1.lastInteractionTime,
            p1.interactionCount
        );
        
        p1.score = newScore1;
        p2.score = newScore2;
        
        emit PlayerAction(msg.sender, 1, newScore1);
        emit PlayerAction(player2, 1, newScore2);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function getEntryFee() external view returns (uint96) {
        return _gameState.entryFee;
    }
}
