// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "./libraries/GameLibrary.sol";
import "./storage/GameStorage.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract PointsSystem is GameStorage, UUPSUpgradeable {
    using GameLibrary for uint32;
    
    error ScoreOverflow();
    error InvalidScore();
    
    function _authorizeUpgrade(address newImplementation) internal override {}
    
    function calculateInteraction(
        address player1,
        address player2
    ) external returns (uint32, uint32) {
        Player storage p1 = _players[player1];
        Player storage p2 = _players[player2];
        
        (uint32 newScore1, uint32 newScore2) = GameLibrary.calculatePoints(
            p1.score,
            p2.score
        );
        
        if (newScore1 > GameLibrary.MAX_SCORE || newScore2 > GameLibrary.MAX_SCORE) 
            revert ScoreOverflow();
            
        p1.score = newScore1;
        p2.score = newScore2;
        
        emit PlayerAction(player1, 1, newScore1);
        emit PlayerAction(player2, 1, newScore2);
        
        return (newScore1, newScore2);
    }
}
