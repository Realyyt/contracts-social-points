const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("Game System", function () {
  let gameFactory;
  let game;
  let owner;
  let player1;
  let player2;

  beforeEach(async function () {
    [owner, player1, player2] = await ethers.getSigners();

    // Deploy GameFactory
    const GameFactory = await ethers.getContractFactory("GameFactory");
    gameFactory = await upgrades.deployProxy(GameFactory, [], {
      initializer: "initialize",
    });

    // Create a new game
    const duration = 7 * 24 * 60 * 60; // 7 days
    const entryFee = ethers.parseEther("0.1"); // 0.1 ETH
    
    const tx = await gameFactory.createGame(duration, entryFee);
    const receipt = await tx.wait();
    
    // Get the game address from the GameCreated event
    const gameCreatedEvent = receipt.logs.find(
      log => log.fragment?.name === 'GameCreated'
    );
    
    if (!gameCreatedEvent) {
      throw new Error("GameCreated event not found");
    }
    
    // Access the gameAddress (first argument of the event)
    const gameAddress = gameCreatedEvent.args[0];
    
    if (!gameAddress) {
      throw new Error("Game address not found in event");
    }

    // Get the Game contract at the created address
    const Game = await ethers.getContractFactory("Game");
    game = Game.attach(gameAddress);

    // Store the entry fee for later use
    this.entryFee = entryFee;
  });

  describe("Game Registration", function () {
    it("Should allow players to register", async function () {
      const username = ethers.encodeBytes32String("player1");
      const pseudonym = ethers.encodeBytes32String("pseudo1");
      
      await expect(game.connect(player1).register(username, pseudonym, {
        value: this.entryFee
      }))
        .to.emit(game, "PlayerAction")
        .withArgs(player1.address, 0, 10); // PlayerAction(address player, uint8 actionType, uint32 newScore)
    });

    it("Should not allow registration with incorrect fee", async function () {
      const username = ethers.encodeBytes32String("player1");
      const pseudonym = ethers.encodeBytes32String("pseudo1");
      const incorrectFee = ethers.parseEther("0.05");

      await expect(
        game.connect(player1).register(username, pseudonym, {
          value: incorrectFee
        })
      ).to.be.revertedWithCustomError(game, "IncorrectEntryFee"); // Changed error name
    });
  });

  // Add more test cases for other functionality
});
