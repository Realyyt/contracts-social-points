// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

interface GameErrors {
    error NotOpen();
    error BadFee();
    error Started();
    error NoPlayers();
    error NotActive();
    error Ended();
    error TooManyInteractions();
    error BadScore();
    error AlreadyRegistered();
    error BadName();
}
