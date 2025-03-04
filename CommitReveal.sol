// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract CommitReveal {
    struct Commit {
        bytes32 commit;
        uint64 block;
        bool revealed;
    }

    mapping(address => Commit) public commits;

    function commit(bytes32 dataHash) internal {
        commits[msg.sender] = Commit(dataHash, uint64(block.number), false);
        emit CommitHash(msg.sender, dataHash);
    }

    function reveal(bytes32 revealHash) internal returns (bool) {
        require(!commits[msg.sender].revealed, "Already revealed");
        require(getHash(revealHash) == commits[msg.sender].commit, "Invalid reveal");

        commits[msg.sender].revealed = true;
        emit RevealHash(msg.sender, revealHash);
        return true;
    }

    function getHash(bytes32 data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }

    event CommitHash(address sender, bytes32 dataHash);
    event RevealHash(address sender, bytes32 revealHash);
}
