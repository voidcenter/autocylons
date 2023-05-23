pragma solidity 0.8.18;


contract GamePlayModel {
    enum GameStatus { PendingStart, MafiaTurn, CastingVotes, GameOver }
    enum PlayerRole { Villager, Mafia }
    enum PlayerState { Dead, Alive }

    mapping(uint256 => GameState) public gameState;
    uint256 numberOfGames = 0;
    uint256[] gameIdList;

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

    function addGameInGameList(uint256 gameId) public {
        gameIdList.push(gameId);
    }

    function getGameIdList() public returns(uint256[] memory) {
        return gameIdList;
    }
}