pragma solidity 0.8.18;


contract GamePlayHelper {
    enum GameStatus { PendingStart, MafiaTurn, CastingVotes, GameOver }
    enum PlayerRole { Villager, Mafia }
    enum PlayerState { Dead, Alive }

    mapping(address => uint256) userToAddressVoteMap;
    mapping(uint256 => GameState) public gameState;
    uint256 numberOfGames = 0;
    uint256[] gameIdList;
    uint randNonce = 0;

    struct Player {
        string name;
        address id;
        bool startGame;
        PlayerRole role;
        PlayerState state;
    }

    struct Vote {
        uint256 roundNumber;
        Player voter;
        Player votedAgainst;
    }

    struct MafiaKillings {
        uint256 roundNumber;
        Player mafia;
        Player killedPlayer;
    }

    struct GameState {
        GameStatus currentState;
        Player[] players;
        Vote[] votes;
        MafiaKillings[] mafiaKillings;
        uint256 roundNumber;
    }

    function isPlayerMafia(address playerId, uint256 _gameId) public returns (bool) {
        GameState memory gameStateInfo = gameState[_gameId];
        if (gameStateInfo.players[getPlayerIndex(playerId, _gameId)].role == PlayerRole.Mafia) {
            return true;
        }
        return false;
    }

    function isGameStateCorrect(uint256 gameId, GameStatus gameStatus) public returns (bool) {
        GameState memory gameStateInfo = gameState[gameId];
        if (gameStateInfo.currentState == gameStatus) {
            return true;
        }
        return false;
    }

    function isExistingGame(uint256 gameId) public returns (bool) {
        for (uint256 i = 0; i < gameIdList.length; i++) {
            if (gameIdList[i] == gameId) {
                if (gameState[gameId].currentState != GameStatus.GameOver)
                    return true;
            }
        }
        return false;
    }


    function allPlayersStartedGame(uint256 _gameId) public returns (bool) {
        GameState memory gameStateInfo = gameState[_gameId];
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (!gameStateInfo.players[i].startGame) {
                return false;
            }
        }
        return true;
    }

    function getPlayerIndex(address _playerId, uint256 _gameId) public returns (uint256) {
        GameState memory gameStateInfo = gameState[_gameId];
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (gameStateInfo.players[i].id == _playerId) {
                return i;
            }
        }
        return gameStateInfo.players.length + 10;
    }

    function getPlayerIndexFromName(string memory _playerName, uint256 _gameId) public returns (uint256) {
        GameState memory gameStateInfo = gameState[_gameId];
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (compareString(gameStateInfo.players[i].name, _playerName)) {
                return i;
            }
        }
        return gameStateInfo.players.length + 10;
    }

    function isPlayerAlive(uint256 index, uint256 _gameId) public returns (bool) {
        GameState memory gameStateInfo = gameState[_gameId];
        if (gameStateInfo.players[index].state == PlayerState.Alive) {
            return true;
        }
        return false;
    }


    function checkWinningCondition(uint256 _gameId) public returns (bool) {
        GameState memory gameStateInfo = gameState[_gameId];
        uint256 aliveVillagersCount = 0;
        uint256 aliveMafiaCount = 0;
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (gameStateInfo.players[i].state == PlayerState.Alive && gameStateInfo.players[i].role == PlayerRole.Villager) {
                aliveVillagersCount++;
            }
        }
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (gameStateInfo.players[i].state == PlayerState.Alive && gameStateInfo.players[i].role == PlayerRole.Mafia) {
                aliveMafiaCount++;
            }
        }
        if (aliveVillagersCount <= aliveMafiaCount) {
            return true;
        }
        return false;
    }

    function checkAllAlivePlayersVoted(uint256 _gameId, uint256 roundNumber) public returns (bool) {
        GameState memory gameStateInfo = gameState[_gameId];
        uint256 aliveCount = 0;
        uint256 votesCount = 0;
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (gameStateInfo.players[i].state == PlayerState.Alive) {
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
        GameState memory gameStateInfo = gameState[_gameId];
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
        GameState memory gameStateInfo = gameState[_gameId];
        uint256 maxVote = 0;
        address votedPlayer;
        for (uint256 i = 0; i < gameStateInfo.votes.length; i++) {
            if (gameStateInfo.votes[i].roundNumber == roundNumber) {
                Player memory votedAgainst = gameStateInfo.votes[i].votedAgainst;
                userToAddressVoteMap[votedAgainst.id]++;
                if (maxVote < userToAddressVoteMap[votedAgainst.id]) {
                    maxVote = userToAddressVoteMap[votedAgainst.id];
                    votedPlayer = votedAgainst.id;
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

    function randMod(uint _modulus) public returns(uint)
    {
        // increase nonce
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % _modulus;
    }

    function createPlayer(string memory _userName, uint256 _gameId) public {
        Player memory player = Player(_userName, msg.sender, false, PlayerRole.Villager, PlayerState.Alive);
        gameState[_gameId].players.push(player);
    }

    function getGameState(uint256 _gameId) public returns (GameState memory) {
        return gameState[_gameId];
    }

    function incrementGame() public {
        numberOfGames++;
    }

    function getGameNumber() public returns (uint256) {
        return numberOfGames;
    }

    function createMafiaKillings(uint256 roundNumber, Player memory mafia, Player memory killedPlayer, uint256 _gameId) public {
        gameState[_gameId].mafiaKillings.push(MafiaKillings(roundNumber, mafia, killedPlayer));
    }

    function createVote(uint256 roundNumber, Player memory voter, Player memory votedAgainst, uint256 _gameId) public {
        gameState[_gameId].votes.push(Vote(roundNumber, voter, votedAgainst));
    }
}