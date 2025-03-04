# Rock-Paper-Scissors-Lizard-Spock (RPSLS) Smart Contract

## Overview
This Solidity smart contract implements a Rock-Paper-Scissors-Lizard-Spock (RPSLS) game using a commit-reveal scheme. It allows only specific allowed players to participate, ensures fair gameplay, and prevents front-running attacks. The contract locks bets, verifies player choices upon reveal, determines the winner, and enforces a timeout mechanism if a game stalls.

## Files and Structure
The project is structured into multiple Solidity files for modularity and maintainability:

- `RPSLS.sol`: Main contract that manages game flow, player registration, and bet handling.
- `CommitReveal.sol`: Implements the commit-reveal scheme for hiding player choices.
- `GameLogic.sol`: Handles game rules, winner determination, and scoring.

## Key Functionalities Explained

### 1. Locking Player's Money
When a player commits their move, they must send a bet. This bet is stored in the contract and remains locked until the game is resolved:

```solidity
require(msg.value > 0, "Must send a bet");
game = Game(msg.sender, address(0), msg.value, uint64(block.number), true);
```
- The `msg.value` ensures that the player deposits a bet.
- The bet amount is locked in the contract.
- It remains in the contract until both players reveal their moves and a winner is determined.

### 2. Hiding Player's Choice (Commit-Reveal Mechanism)
To prevent front-running, the contract uses a commit-reveal scheme:

```solidity
function commit(bytes32 dataHash) public payable onlyAllowedPlayers {
    require(game.active == false, "Game in progress");
    require(msg.value > 0, "Must send a bet");
    game = Game(msg.sender, address(0), msg.value, uint64(block.number), true);
    commits[msg.sender] = Commit(dataHash, uint64(block.number), false);
    emit CommitHash(msg.sender, dataHash);
}
```
- The player submits a **hash** of their choice instead of revealing it immediately.
- The actual move is revealed later using the `reveal` function.
- This prevents the second player from knowing and countering the first player’s move.

### 3. Handling Delays When Not Enough Players Join
If a second player does not join, the first player's bet could be locked indefinitely. To prevent this, a timeout function allows the first player to reclaim their bet:

```solidity
function timeout() public onlyAllowedPlayers {
    require(game.active, "No active game");
    require(block.number > game.startBlock + 250, "Not enough time passed");
    
    if (game.player2 == address(0)) {
        payable(game.player1).transfer(game.betAmount);
    } else {
        payable(game.player1).transfer(game.betAmount / 2);
        payable(game.player2).transfer(game.betAmount / 2);
    }
    
    resetGame();
}
```
- If the second player does not join within **250 blocks**, the first player gets their money back.
- If both players joined but one fails to reveal their choice, the bet is refunded equally.
- This prevents funds from being permanently locked in the contract.

### 4. Revealing the Result & Determining the Winner
Once both players reveal their choices, the contract determines the winner:

```solidity
function reveal(bytes32 revealHash) public onlyAllowedPlayers {
    require(game.active, "No active game");
    require(!commits[msg.sender].revealed, "Already revealed");
    require(getHash(revealHash) == commits[msg.sender].commit, "Invalid reveal");
    
    commits[msg.sender].revealed = true;
    emit RevealHash(msg.sender, revealHash);
    
    if (commits[game.player1].revealed && commits[game.player2].revealed) {
        settleGame(revealHash);
    }
}
```
- Players reveal their choices by providing the original input used to create their commit hash.
- The contract verifies that the hash matches the committed value.
- Once both players reveal their choices, the contract calls `settleGame()` to determine the winner and distribute the bets.

### 5. Determining the Winner
The contract follows the rules of Rock-Paper-Scissors-Lizard-Spock:

```solidity
function determineWinner(uint8 p1, uint8 p2) internal pure returns (uint8) {
    if (p1 == p2) return 0; // Tie
    if ((p1 + 1) % max == p2 || (p1 + 3) % max == p2) {
        return 2; // Player 2 wins
    }
    return 1; // Player 1 wins
}
```
- Each choice is represented by a number (0 to 4).
- The function checks who wins based on modulo calculations.
- The contract transfers the locked bets to the winner.

## How to Deploy and Test
### 1. Deploying the Contract
1. Open [Remix Ethereum IDE](https://remix.ethereum.org/).
2. Upload all `.sol` files into the workspace.
3. Compile each file using Solidity version `>=0.8.2 <0.9.0`.
4. Deploy `RPSLS.sol` using an Ethereum test network (e.g., **Goerli, Sepolia**).

### 2. Playing the Game
1. **Player 1 commits:** Call `commit(bytes32 hash)` with their choice hash and bet amount.
2. **Player 2 joins:** Call `join(bytes32 hash)` with an equal bet amount.
3. **Both players reveal:** Call `reveal(bytes32 choice)` to reveal their move.
4. **Contract determines the winner and pays out the bet.**

### 3. Handling Game Stalls
- If Player 2 doesn’t join, Player 1 can call `timeout()` after **250 blocks** to recover funds.
- If a player doesn’t reveal their choice, both players get refunded equally after **250 blocks**.
