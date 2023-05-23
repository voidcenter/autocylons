pragma solidity 0.8.18;

import "./GamePlayHelper.sol";

contract GameLobby {
    GamePlayHelper gamePlayHelper;
    GamePlayHelper.GameStatus public myEnumValue;
    constructor(address counterAddress) {
        gamePlayHelper = GamePlayHelper(counterAddress);
    }

    event GameStatusUpdated (uint gameId, GamePlayHelper.GameStatus previousGameState, GamePlayHelper.GameStatus currentGameStatus);

    function joinLobby(string memory _userName, uint256 _gameId) public {
        require(gamePlayHelper.isExistingGame(_gameId), "Invalid game Id");
        GamePlayHelper.GameState memory gameStateInfo = gamePlayHelper.getGameState(_gameId);
        uint256 playerIdx = gamePlayHelper.getPlayerIndexFromName(_userName, _gameId);
        bool playerExist = true;
        if (playerIdx >= gameStateInfo.players.length) {
            playerExist = false;
        }
        require(!playerExist, "Villager does not exist");
        gamePlayHelper.createPlayer(_userName, _gameId);
    }

    function createGame(string memory _userName) public returns (uint256) {
        gamePlayHelper.incrementGame();
        uint256 numberOfGames = gamePlayHelper.getGameNumber();
        GamePlayHelper.GameState memory gameStateInfo = gamePlayHelper.getGameState(numberOfGames);
        gamePlayHelper.createPlayer(_userName, numberOfGames);
        gameStateInfo.roundNumber = 0;
        gameStateInfo.currentState = GamePlayHelper.GameStatus.PendingStart;
        return numberOfGames;
    }

    function startGame(uint256 _gameId) public {
        // Randomly assign a member as mafia just when the last player moves the state to start game.
        require(gamePlayHelper.isExistingGame(_gameId), "Invalid game Id");
        GamePlayHelper.GameState memory gameStateInfo = gamePlayHelper.getGameState(_gameId);

        uint256 playerIdx = gamePlayHelper.getPlayerIndex(msg.sender, _gameId);
        bool playerExist = true;
        if (playerIdx >= gameStateInfo.players.length) {
            playerExist = false;
        }
        require(playerExist, "Player not in game");

        gameStateInfo.players[gamePlayHelper.getPlayerIndex(msg.sender, _gameId)].startGame = true;
        if (gamePlayHelper.allPlayersStartedGame(_gameId)) {
            gameStateInfo.currentState = GamePlayHelper.GameStatus.MafiaTurn;
            uint idx = gamePlayHelper.randMod(gameStateInfo.players.length);
            gameStateInfo.players[idx].role = GamePlayHelper.PlayerRole.Mafia;
        }
    }



    function mafiaKills(string memory _killedVillagerName, uint256 _gameId) public {
        // Ensure both the players are in the relevant game id and the game exists. Ensure the state of the game is apt.
        // Kill the player and alter the state of the game.
        require(gamePlayHelper.isExistingGame(_gameId), "Game id invalid.");
        require(gamePlayHelper.isPlayerMafia(msg.sender, _gameId), "Player is not a Mafia");
        require(gamePlayHelper.isGameStateCorrect(_gameId, GamePlayHelper.GameStatus.MafiaTurn), "Invalid game state");
        uint256 villagerIdx = gamePlayHelper.getPlayerIndexFromName(_killedVillagerName, _gameId);
        bool villagerExist = true;
        GamePlayHelper.GameState memory gameStateInfo = gamePlayHelper.getGameState(_gameId);
        if (villagerIdx >= gameStateInfo.players.length) {
            villagerExist = false;
        }
        require(villagerExist, "Villager does not exist");
        address villagerAddress = gameStateInfo.players[villagerIdx].id;
        require(!gamePlayHelper.isPlayerMafia(villagerAddress, _gameId), "Invalid Villager");
        uint256 mafiaIdx = gamePlayHelper.getPlayerIndex(msg.sender, _gameId);
        require(gamePlayHelper.isPlayerAlive(mafiaIdx, _gameId), "Msg sender is not alive");
        uint256 idx = gamePlayHelper.getPlayerIndexFromName(_killedVillagerName, _gameId);
        require(gamePlayHelper.isPlayerAlive(villagerIdx, _gameId), "Villager is already dead");

        gameStateInfo.players[villagerIdx].state = GamePlayHelper.PlayerState.Dead;
        uint256 roundNumber = gameStateInfo.roundNumber;
        gamePlayHelper.createMafiaKillings(roundNumber,
            gameStateInfo.players[mafiaIdx], gameStateInfo.players[villagerIdx], _gameId);
        GamePlayHelper.GameStatus previousStatus = gameStateInfo.currentState;
        if (gamePlayHelper.checkWinningCondition(_gameId)) {
            gameStateInfo.currentState = GamePlayHelper.GameStatus.GameOver;
        } else {
            gameStateInfo.currentState = GamePlayHelper.GameStatus.CastingVotes;
        }

        GamePlayHelper.GameStatus status = gameStateInfo.currentState;
        emit GameStatusUpdated(_gameId, previousStatus, status);
    }

    function castVotes(string memory _votedAgainstName, uint256 _gameId) public {
        // Ensure both the players are in the relevant game id and the game exists. Ensure the state of the game is apt.
        // Mark the vote and store it.
        // If all alive players have voted - make sure to move the state. If the game gets over emit apt event.

        require(gamePlayHelper.isExistingGame(_gameId), "Game id invalid.");
        require(gamePlayHelper.isGameStateCorrect(_gameId, GamePlayHelper.GameStatus.CastingVotes), "Invalid game state");
        uint256 voterIdx = gamePlayHelper.getPlayerIndex(msg.sender, _gameId);
        bool voterExist = true;
        GamePlayHelper.GameState memory gameStateInfo = gamePlayHelper.getGameState(_gameId);
        if (voterIdx >= gameStateInfo.players.length) {
            voterExist = false;
        }
        require(voterExist, "Voter does not exist");
        uint256 votedAgainstIdx = gamePlayHelper.getPlayerIndexFromName(_votedAgainstName, _gameId);
        bool votedAgainstExist = true;
        if (votedAgainstIdx >= gameStateInfo.players.length) {
            votedAgainstExist = false;
        }
        require(votedAgainstExist, "Invalid voted against");
        require(gamePlayHelper.isPlayerAlive(voterIdx, _gameId), "Voter not alive");
        require(gamePlayHelper.isPlayerAlive(votedAgainstIdx, _gameId), "Voted Against not alive");
        uint256 roundNumber = gameStateInfo.roundNumber;
        require(gamePlayHelper.checkPlayerAlreadyVoted(_gameId, roundNumber), "Voter has already voted");

        gamePlayHelper.createVote(roundNumber, gameStateInfo.players[voterIdx],
            gameStateInfo.players[votedAgainstIdx], _gameId);
        if (gamePlayHelper.checkAllAlivePlayersVoted(_gameId, roundNumber)) {
            uint256 killedPlayerIdx = gamePlayHelper.checkWhoWasVotedOut(_gameId, roundNumber);
            gameStateInfo.players[killedPlayerIdx].state = GamePlayHelper.PlayerState.Dead;

            GamePlayHelper.GameStatus previousStatus = gameStateInfo.currentState;
            if (gamePlayHelper.checkWinningCondition(_gameId)) {
                gameStateInfo.currentState = GamePlayHelper.GameStatus.GameOver;
            } else {
                gameStateInfo.currentState = GamePlayHelper.GameStatus.MafiaTurn;
                gameStateInfo.roundNumber++;
            }
            GamePlayHelper.GameStatus status = gameStateInfo.currentState;
            emit GameStatusUpdated(_gameId, previousStatus, status);
        }
    }
}