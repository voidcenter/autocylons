pragma solidity 0.8.18;
import "./GamePlayModel.sol";
contract GamePlayHelper {

    GamePlayModel gamePlayModel;
    uint randNonce = 0;
    constructor(address counterAddress) {
        gamePlayModel = GamePlayModel(counterAddress);
    }

    function isPlayerMafia(address playerId, uint256 _gameId) public returns (bool) {
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        if (gameStateInfo.players[getPlayerIndex(playerId, _gameId)].role == GamePlayModel.PlayerRole.Mafia) {
            return true;
        }
        return false;
    }

    function isGameStateCorrect(uint256 _gameId, GamePlayModel.GameStatus gameStatus) public returns (bool) {
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        if (gameStateInfo.currentState == gameStatus) {
            return true;
        }
        return false;
    }

    function isExistingGame(uint256 _gameId) public returns (bool) {
        uint256[] memory _gameIdList = gamePlayModel.getGameIdList();
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        for (uint256 i = 0; i < _gameIdList.length; i++) {
            if (_gameIdList[i] == _gameId) {
                if (gameStateInfo.currentState != GamePlayModel.GameStatus.GameOver)
                    return true;
            }
        }
        return false;
    }


    function allPlayersStartedGame(uint256 _gameId) public returns (bool) {
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (!gameStateInfo.players[i].startGame) {
                return false;
            }
        }
        return true;
    }

    function getPlayerIndex(address _playerId, uint256 _gameId) public returns (uint256) {
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (gameStateInfo.players[i].id == _playerId) {
                return i;
            }
        }
        return gameStateInfo.players.length + 10;
    }

    function getPlayerIndexFromName(string memory _playerName, uint256 _gameId) public returns (uint256) {
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (compareString(gameStateInfo.players[i].name, _playerName)) {
                return i;
            }
        }
        return gameStateInfo.players.length + 10;
    }

    function isPlayerAlive(uint256 index, uint256 _gameId) public returns (bool) {
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        if (gameStateInfo.players[index].state == GamePlayModel.PlayerState.Alive) {
            return true;
        }
        return false;
    }


    function checkWinningCondition(uint256 _gameId) public returns (bool) {
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        uint256 aliveVillagersCount = 0;
        uint256 aliveMafiaCount = 0;
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (gameStateInfo.players[i].state == GamePlayModel.PlayerState.Alive &&
                gameStateInfo.players[i].role == GamePlayModel.PlayerRole.Villager) {
                aliveVillagersCount++;
            }
        }
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (gameStateInfo.players[i].state == GamePlayModel.PlayerState.Alive &&
                gameStateInfo.players[i].role == GamePlayModel.PlayerRole.Mafia) {
                aliveMafiaCount++;
            }
        }
        if (aliveVillagersCount <= aliveMafiaCount) {
            return true;
        }
        return false;
    }

    function checkAllAlivePlayersVoted(uint256 _gameId, uint256 roundNumber) public returns (bool) {
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        uint256 aliveCount = 0;
        uint256 votesCount = 0;
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (gameStateInfo.players[i].state == GamePlayModel.PlayerState.Alive) {
                aliveCount++;
            }
        }
        for (uint256 i = 0; i < gameStateInfo.votes.length; i++) {
            if (gameStateInfo.votes[i].roundNumber == roundNumber) {
                votesCount++;
            }
        }
        if (aliveCount == votesCount) {
            return true;
        }
        return false;
    }

    function checkPlayerAlreadyVoted(uint256 _gameId, uint256 roundNumber) public returns (bool) {
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        for (uint256 i = 0; i < gameStateInfo.votes.length; i++) {
            if (gameStateInfo.votes[i].roundNumber == roundNumber) {
                if (gameStateInfo.votes[i].voter.id == msg.sender) {
                    return true;
                }
            }
        }
        return false;
    }

    function checkWhoWasVotedOut(uint256 _gameId, uint256 roundNumber) public returns (uint256) {
        GamePlayModel.GameState memory gameStateInfo = gamePlayModel.getGameState(_gameId);
        uint256 maxVote = 0;
        address votedPlayer;
        for (uint256 i = 0; i < gameStateInfo.votes.length; i++) {
            uint256 count = 0;
            if (gameStateInfo.votes[i].roundNumber == roundNumber) {
                GamePlayModel.Player memory votedAgainstI = gameStateInfo.votes[i].votedAgainst;
                for (uint256 j = 0; j < gameStateInfo.votes.length; j++) {
                    if (gameStateInfo.votes[j].roundNumber == roundNumber) {
                        GamePlayModel.Player memory votedAgainstJ = gameStateInfo.votes[j].votedAgainst;
                        if (votedAgainstI.id == votedAgainstJ.id) {
                            count++;
                        }
                    }
                }
                if (count >= maxVote) {
                    maxVote = count;
                    votedPlayer = votedAgainstI.id;
                }
            }
        }

        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (gameStateInfo.players[i].id == votedPlayer) {
                return i;
            }
        }
        return 0;
    }

    function compareString(string memory str1, string memory str2) public pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    function randMod(uint _modulus) public returns(uint){
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % _modulus;
    }
}