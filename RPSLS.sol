// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./PlayerManager.sol";
import "./GameLogic.sol";

contract RPSLS is PlayerManager, GameLogic {
    struct Game {
        address player1;
        address player2;
        uint256 betAmount;
        uint64 startBlock;
        bool active;
    }

    Game public game;

    function commitMove(bytes32 dataHash) public payable onlyAllowedPlayers {
        require(!game.active, "Game in progress");
        require(msg.value > 0, "Must send a bet");

        game = Game(msg.sender, address(0), msg.value, uint64(block.number), true);
        commit(dataHash);
    }

    function joinGame(bytes32 dataHash) public payable onlyAllowedPlayers {
        require(game.active, "No active game");
        require(game.player2 == address(0), "Game full");
        require(msg.value == game.betAmount, "Bet mismatch");

        game.player2 = msg.sender;
        commit(dataHash);
    }

    function revealMove(bytes32 revealHash) public onlyAllowedPlayers {
        require(game.active, "No active game");
        require(reveal(revealHash), "Reveal failed");

        if (commits[game.player1].revealed && commits[game.player2].revealed) {
            finalizeGame(revealHash);
        }
    }

    function finalizeGame(bytes32 player2Choice) private {
    uint8 p1 = uint8(uint256(commits[game.player1].commit) % max);
    uint8 p2 = uint8(uint256(player2Choice) % max);

    uint8 result = determineWinner(p1, p2);
    address winner;

    if (result == 1) {
        winner = game.player1;
    } else if (result == 2) {
        winner = game.player2;
    } else {
        // Tie: refund both players
        payable(game.player1).transfer(game.betAmount);
        payable(game.player2).transfer(game.betAmount);
        resetGame();
        return;
    }

    // Transfer prize to the winner
    payable(winner).transfer(game.betAmount * 2);
    resetGame();
}


    function resetGame() private {
        delete commits[game.player1];
        delete commits[game.player2];
        delete game;
    }

    function timeout() public onlyAllowedPlayers {
        require(game.active, "No active game");
        require(block.number > game.startBlock + 250, "Too soon");

        if (game.player2 == address(0)) {
            payable(game.player1).transfer(game.betAmount);
        } else {
            payable(game.player1).transfer(game.betAmount / 2);
            payable(game.player2).transfer(game.betAmount / 2);
        }

        resetGame();
    }
}
