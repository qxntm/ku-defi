# Rock-Paper-Scissors-Lizard-Spock (RPSLS) Solidity Game #

## Overview ##
This smart contract implements the Rock-Paper-Scissors-Lizard-Spock (RPSLS) game using the commit-reveal scheme to prevent cheating and front-running attacks. The game is played between two allowed players, and the winner is determined based on predefined game rules.

## Files Structure ##

### 1. `CommitReveal.sol` ###
This contract handles the commit-reveal mechanism, allowing players to securely commit their choices before revealing them later.

- **Functions:**
  - `commit(bytes32 dataHash)`: Allows a player to commit their hashed move.
  - `reveal(bytes32 revealHash)`: Allows a player to reveal their move and validate it against the committed hash.
  - `getHash(bytes32 data)`: Helper function to generate a keccak256 hash.

### 2. `GameLogic.sol` ###
Extends `CommitReveal.sol` and implements the game logic for RPSLS.

- **Functions:**
  - `determineWinner(uint8 p1, uint8 p2)`: Determines the winner based on RPSLS rules.
  - Input validation ensures that player choices are within the range (0-4).

### 3. `RPSLS.sol` ###
The main contract that manages the game lifecycle, player interactions, and bet handling.

- **Functions:**
  - `commit(bytes32 dataHash)`: Player 1 commits a hashed move and places a bet.
  - `join(bytes32 dataHash)`: Player 2 joins the game and commits a move.
  - `reveal(bytes32 revealHash)`: Players reveal their moves and determine the winner.
  - `finalizeGame(bytes32 player2Choice)`: Determines the winner and transfers the bet.
  - `timeout()`: If a player fails to reveal in time, funds are refunded accordingly.
  - `resetGame()`: Resets the game state after completion.

## How It Works ##

1. **Commit Phase:**
   - Players commit their moves using a keccak256 hash.
   - Example: `keccak256(abi.encodePacked(choice, secret))` ensures hidden choice.

2. **Reveal Phase:**
   - Players reveal their moves along with the secret used during commitment.
   - If both players reveal, the winner is determined.

3. **Game Settlement:**
   - If one player wins, they receive the total bet.
   - If it's a tie, both players get their bet refunded.
   - If a player fails to reveal within 250 blocks, a timeout function allows withdrawal.

