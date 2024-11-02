// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

library GameTypes {
    // Game flags
    uint8 constant FLAG_ACTIVE = 1;
    uint8 constant FLAG_STARTED = 2;
    uint8 constant FLAG_PAUSED = 4;
    
    // Game constants
    uint8 constant MAX_DAILY_INTERACTIONS = 10;
    uint32 constant MAX_SCORE = 1_000_000;
    uint8 constant BASE_POINTS = 2;
    uint8 constant MEETUP_POINTS = 4;
    uint8 constant TIME_PERIOD_POINTS = 1;
    uint32 constant TIME_PERIOD = 36000;
    uint32 constant INITIAL_SCORE = 10;
    
    // Custom errors
    error IncorrectEntryFee();
    error InvalidState();
    error PlayerLimit();
    error InvalidInteraction();
    error ScoreOverflow();
    error NotRegistered();
    error AlreadyRegistered();
}
