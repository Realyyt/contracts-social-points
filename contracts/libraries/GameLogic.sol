// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "./GameTypes.sol";

library GameLogic {
    function hasFlag(uint8 flags, uint8 flag) internal pure returns (bool) {
        return flags & flag != 0;
    }

    function calculatePoints(
        uint32 score1,
        uint32 score2
    ) internal pure returns (uint32, uint32) {
        unchecked {
            if (score1 > score2) {
                return (
                    score1 + GameTypes.BASE_POINTS,
                    score2 > GameTypes.BASE_POINTS ? score2 - GameTypes.BASE_POINTS : 0
                );
            }
            return (
                score1 > GameTypes.BASE_POINTS ? score1 - GameTypes.BASE_POINTS : 0,
                score2 + GameTypes.BASE_POINTS
            );
        }
    }

    function calculateTimePoints(
        uint32 lastTime,
        uint32 currentTime
    ) internal pure returns (uint32) {
        unchecked {
            return uint32((currentTime - lastTime) / GameTypes.TIME_PERIOD) * 
                   GameTypes.TIME_PERIOD_POINTS;
        }
    }

    function canInteract(
        uint32 lastTime,
        uint8 count
    ) internal view returns (bool) {
        return block.timestamp >= lastTime + 1 days || 
               count < GameTypes.MAX_DAILY_INTERACTIONS;
    }
}
