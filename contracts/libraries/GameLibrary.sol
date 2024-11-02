// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

library GameLibrary {
    // Constants
    uint8 constant FLAG_ACTIVE = 1;
    uint8 constant FLAG_STARTED = 2;
    uint8 constant FLAG_PAUSED = 4;
    uint8 constant MAX_DAILY_INTERACTIONS = 10;
    uint32 constant MAX_SCORE = 1_000_000;
    uint8 constant INTERACTION_POINTS = 2;
    uint8 constant MEETUP_POINTS = 4;
    uint8 constant TIME_PERIOD_POINTS = 1;
    uint32 constant TIME_PERIOD = 36000; // 10 hours in seconds
    uint32 constant BASE_POINTS = 32;  // Add this line (adjust value as needed)
    
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
                    score1 + INTERACTION_POINTS,
                    score2 > INTERACTION_POINTS ? score2 - INTERACTION_POINTS : 0
                );
            }
            return (
                score1 > INTERACTION_POINTS ? score1 - INTERACTION_POINTS : 0,
                score2 + INTERACTION_POINTS
            );
        }
    }
    
    function updateInteraction(
        uint32 lastTime,
        uint8 count
    ) internal view returns (uint32, uint8) {
        unchecked {
            return block.timestamp >= lastTime + 1 days ? 
                (uint32(block.timestamp), 1) : 
                (lastTime, count + 1);
        }
    }
    
    function calculateTimePoints(
        uint32 lastTime,
        uint32 currentTime
    ) internal pure returns (uint32) {
        unchecked {
            return uint32((currentTime - lastTime) / TIME_PERIOD) * TIME_PERIOD_POINTS;
        }
    }
    
    function canInteract(
        uint32 lastInteractionTime,
        uint32 interactionCount,
        uint32 maxDaily
    ) internal view returns (bool) {
        uint32 daysSinceLastInteraction = uint32((block.timestamp - lastInteractionTime) / 1 days);
        return daysSinceLastInteraction >= 1 || interactionCount < maxDaily;
    }
}
