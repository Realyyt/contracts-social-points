// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

library GameUtils {
    function validateScore(uint32 score, uint32 maxScore) internal pure returns (bool) {
        return score <= maxScore && score > 0;
    }

    function calculateTimeBasedPoints(
        uint32 lastTime,
        uint32 currentTime,
        uint8 pointsPerPeriod
    ) internal pure returns (uint32) {
        return uint32((currentTime - lastTime) / 36000) * pointsPerPeriod;
    }

    function canInteract(
        uint256 lastTime,
        uint256 count,
        uint256 maxInteractions
    ) internal view returns (bool) {
        return block.timestamp >= lastTime + 1 days || count < maxInteractions;
    }
}
