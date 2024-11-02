// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title PrizeStorage - Stores prize-related data
/// @notice Manages the storage of prize pools and prize distributions
contract PrizeStorage is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    mapping(address => uint256) public pendingPrizes;
    uint256 public totalPrizePool;
    uint8[10] public prizePercentages;

    event PrizePoolUpdated(uint256 newTotal);
    event PrizePercentagesUpdated(uint8[10] newPercentages);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the PrizeStorage contract
    /// @param _owner Address of the contract owner
    function initialize(address _owner) external initializer {
        __Ownable_init(_owner);
        __UUPSUpgradeable_init();
        prizePercentages = [25, 20, 15, 10, 8, 7, 5, 4, 3, 3];
    }

    /// @notice Authorizes an upgrade to a new implementation
    /// @param newImplementation Address of the new implementation
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// @notice Updates the prize distribution percentages
    /// @param _newPercentages Array of new percentage values
    function updatePrizePercentages(uint8[10] memory _newPercentages) external onlyOwner {
        uint16 total;
        for (uint8 i = 0; i < 10; i++) {
            total += _newPercentages[i];
        }
        require(total == 100, "Must total 100");
        prizePercentages = _newPercentages;
        emit PrizePercentagesUpdated(_newPercentages);
    }

    /// @notice Gets the prize percentage for a specific position
    /// @param index Position index (0-9)
    /// @return uint8 Prize percentage for the position
    function getPrizePercentage(uint8 index) external view returns (uint8) {
        return prizePercentages[index];
    }

    /// @notice Gets the pending prize amount for a winner
    /// @param _winner Address of the winner
    /// @return uint256 Pending prize amount
    function getPendingPrize(address _winner) external view returns (uint256) {
        return pendingPrizes[_winner];
    }

    /// @notice Sets a pending prize for a winner
    /// @param _winner Address of the winner
    /// @param _amount Prize amount
    function setPendingPrize(address _winner, uint256 _amount) external onlyOwner {
        pendingPrizes[_winner] = _amount;
    }

    /// @notice Clears a pending prize after it's claimed
    /// @param _winner Address of the winner
    function clearPendingPrize(address _winner) external onlyOwner {
        pendingPrizes[_winner] = 0;
    }

    /// @notice Updates the total prize pool amount
    /// @param _newTotal New total prize pool value
    function updateTotalPrizePool(uint256 _newTotal) external onlyOwner {
        totalPrizePool = _newTotal;
        emit PrizePoolUpdated(_newTotal);
    }
}
