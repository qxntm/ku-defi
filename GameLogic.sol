// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./CommitReveal.sol";

contract GameLogic is CommitReveal {
    uint8 public max = 5; // RPSLS choices: 0-4

    function determineWinner(uint8 p1, uint8 p2) internal view returns (uint8) {
        require(
            p1 < max && p2 < max,
            "Invalid move: Choices must be between 0 and 4"
        );

        if (p1 == p2) return 0; // Tie
        if ((p1 + 1) % max == p2 || (p1 + 3) % max == p2) {
            return 2; // Player 2 wins
        }
        return 1; // Player 1 wins
    }
}
