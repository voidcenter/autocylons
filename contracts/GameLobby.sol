pragma solidity 0.8.18;

import "./GamePlayModel.sol";
import "./GamePlayHelper.sol";

contract GameLobby {
    GamePlayModel gamePlayModel;
    GamePlayHelper gamePlayHelper;
    constructor(address gamePlayModelAddress, address gamePlayHelperAddress) {
        gamePlayModel = GamePlayModel(gamePlayModelAddress);
        gamePlayHelper = GamePlayHelper(gamePlayHelperAddress);
    }

    event GameStatusUpdated (uint256 gameId, GamePlayModel.GameStatus previousGameState, GamePlayModel.GameStatus currentGameStatus);
    event Debug (uint256 gameId, string msg);
    event GameOverEvent(uint256 gameId, GamePlayModel.Winner winner);

    function joinLobby(string memory _userName, uint256 _gameId) public {
        require(gamePlayHelper.isExistingGame(_gameId), "Invalid game Id");
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        uint256 playerIdx = gamePlayHelper.getPlayerIndexFromName(_userName, _gameId);
        bool playerExist = true;
        if (playerIdx >= gameStateInfo.players.length) {
            playerExist = false;
        }
        require(!playerExist, "Villager does not exist");
        gamePlayModel.createPlayer(_userName, _gameId);
    }

    function createGame(string memory _userName) public returns (uint256) {
        emit Debug(gamePlayModel.getGameNumber(), "Game id before increment");
        gamePlayModel.incrementGame();
        emit Debug(gamePlayModel.getGameNumber(), "Game id was incremented");
        uint256 numberOfGames = gamePlayModel.getGameNumber();
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(numberOfGames);
        gamePlayModel.createPlayer(_userName, numberOfGames);
        gameStateInfo.roundNumber = 0;
        gameStateInfo.currentState = GamePlayModel.GameStatus.PendingStart;
        gamePlayModel.addGameInGameList(numberOfGames);
        return numberOfGames;
    }

    function startGame(uint256 _gameId) public {
        // Randomly assign a member as mafia just when the last player moves the state to start game.
        require(gamePlayHelper.isExistingGame(_gameId), "Invalid game Id");
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);

        uint256 playerIdx = gamePlayHelper.getPlayerIndex(msg.sender, _gameId);
        bool playerExist = true;
        if (playerIdx >= gameStateInfo.players.length) {
            playerExist = false;
        }
        require(playerExist, "Player not in game");

        gameStateInfo.players[gamePlayHelper.getPlayerIndex(msg.sender, _gameId)].startGame = true;
        if (gamePlayHelper.allPlayersStartedGame(_gameId)) {
            gameStateInfo.currentState = GamePlayModel.GameStatus.MafiaTurn;
            uint idx = gamePlayHelper.randMod(gameStateInfo.players.length);
            gameStateInfo.players[idx].role = GamePlayModel.PlayerRole.Mafia;
        }
    }



    function mafiaKills(string memory _killedVillagerName, uint256 _gameId) public {
        // Ensure both the players are in the relevant game id and the game exists. Ensure the state of the game is apt.
        // Kill the player and alter the state of the game.
        require(gamePlayHelper.isExistingGame(_gameId), "Game id invalid.");
        require(gamePlayHelper.isPlayerMafia(msg.sender, _gameId), "Player is not a Mafia");
        require(gamePlayHelper.isGameStateCorrect(_gameId, GamePlayModel.GameStatus.MafiaTurn), "Invalid game state");
        uint256 villagerIdx = gamePlayHelper.getPlayerIndexFromName(_killedVillagerName, _gameId);
        bool villagerExist = true;
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
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

        gameStateInfo.players[villagerIdx].state = GamePlayModel.PlayerState.Dead;
        uint256 roundNumber = gameStateInfo.roundNumber;
        gamePlayModel.createMafiaKillings(roundNumber,
            gameStateInfo.players[mafiaIdx], gameStateInfo.players[villagerIdx], _gameId);
        GamePlayModel.GameStatus previousStatus = gameStateInfo.currentState;
        if (gamePlayHelper.checkWinningCondition(_gameId)) {
            gameStateInfo.currentState = GamePlayModel.GameStatus.GameOver;
            emit GameOverEvent(_gameId, GamePlayModel.Winner.Mafia);
        } else {
            gameStateInfo.currentState = GamePlayModel.GameStatus.CastingVotes;
        }

        GamePlayModel.GameStatus status = gameStateInfo.currentState;
        emit GameStatusUpdated(_gameId, previousStatus, status);
    }

    function castVotes(string memory _votedAgainstName, uint256 _gameId) public {
        // Ensure both the players are in the relevant game id and the game exists. Ensure the state of the game is apt.
        // Mark the vote and store it.
        // If all alive players have voted - make sure to move the state. If the game gets over emit apt event.

        require(gamePlayHelper.isExistingGame(_gameId), "Game id invalid.");
        require(gamePlayHelper.isGameStateCorrect(_gameId, GamePlayModel.GameStatus.CastingVotes), "Invalid game state");
        uint256 voterIdx = gamePlayHelper.getPlayerIndex(msg.sender, _gameId);
        bool voterExist = true;
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
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

        gamePlayModel.createVote(roundNumber, gameStateInfo.players[voterIdx],
            gameStateInfo.players[votedAgainstIdx], _gameId);
        if (gamePlayHelper.checkAllAlivePlayersVoted(_gameId, roundNumber)) {
            uint256 killedPlayerIdx = gamePlayHelper.checkWhoWasVotedOut(_gameId, roundNumber);
            gameStateInfo.players[killedPlayerIdx].state = GamePlayModel.PlayerState.Dead;

            GamePlayModel.GameStatus previousStatus = gameStateInfo.currentState;
            if (gamePlayHelper.checkWinningCondition(_gameId)) {
                gameStateInfo.currentState = GamePlayModel.GameStatus.GameOver;
                emit GameOverEvent(_gameId, GamePlayModel.Winner.Mafia);
            } else if (gameStateInfo.players[killedPlayerIdx].role == GamePlayModel.PlayerRole.Mafia) {
                gameStateInfo.currentState = GamePlayModel.GameStatus.GameOver;
                emit GameOverEvent(_gameId, GamePlayModel.Winner.Villager);
            } else {
                gameStateInfo.currentState = GamePlayModel.GameStatus.MafiaTurn;
                gameStateInfo.roundNumber++;
            }
            GamePlayModel.GameStatus status = gameStateInfo.currentState;
            emit GameStatusUpdated(_gameId, previousStatus, status);
        }
    }
}