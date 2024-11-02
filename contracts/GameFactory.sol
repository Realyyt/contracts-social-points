// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import './Game.sol';

/// @title GameFactory - Creates new game instances
/// @notice Factory contract for deploying new game instances
contract GameFactory is 
    Initializable, 
    OwnableUpgradeable, 
    UUPSUpgradeable, 
    PausableUpgradeable 
{
    event GameFactoryInitialized();
    event GameCreated(address indexed gameAddress, uint32 duration, uint256 entryFee);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the GameFactory contract
    /// @custom:oz-upgrades-unsafe-allow-initialize
    function initialize() external initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __Pausable_init();
        emit GameFactoryInitialized();
    }

    /// @notice Authorizes an upgrade to a new implementation
    /// @dev Only callable by owner
    /// @param newImplementation The address of the new implementation
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// @notice Creates a new game instance
    /// @dev Only callable by owner when contract is not paused
    /// @param _duration Duration of the game in seconds
    /// @param _entryFee Entry fee for the game
    /// @return The address of the newly created game
    function createGame(uint32 _duration, uint256 _entryFee) 
        external 
        onlyOwner 
        whenNotPaused 
        returns (address) 
    {
        Game newGame = new Game();
        newGame.initialize(_duration, uint96(_entryFee), msg.sender);
        emit GameCreated(address(newGame), _duration, _entryFee);
        return address(newGame);
    }

    /// @notice Pauses the contract
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpauses the contract
    function unpause() external onlyOwner {
        _unpause();
    }

    
}
