pragma solidity ^0.5.0;

contract Game {
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
        address payable id;
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

    event GameStatusUpdated (uint gameId, GameStatus previousGameState, GameStatus currentGameStatus);
    event VotingConversations(uint gameId, address sender, string msg);




    constructor() public {
    }

    function joinLobby(string memory _userName, uint256 _gameId) public {
        require(isExistingGame(_gameId), "Invalid game Id");
        require(!isPlayerAlreadyInGame(_gameId, msg.sender), "Player already in game");

        Player memory player = Player(_userName, msg.sender, false, PlayerRole.Villager, PlayerState.Alive);
        gameState[_gameId].players.push(player);
    }

    function createGame(string memory _userName) public returns (uint256) {
        // Init objects which need to go inside GameState
//        Player[] initPlayers = new Player[](numberOfPlayers);
//        Player memory player = Player(_userName, msg.sender, false, PlayerRole.Villager, PlayerState.Alive);
//        initPlayers.push(player);
//        Vote[] memory votes;
//        MafiaKillings[] memory mafiaKillings;

//        numberOfGames++;
//        gameState[numberOfGames] = GameState(GameStatus.PendingStart, initPlayers, votes, mafiaKillings, 0);
//        gameIdList.push(numberOfGames);
        numberOfGames++;
        Player memory player = Player(_userName, msg.sender, false, PlayerRole.Villager, PlayerState.Alive);
        gameState[numberOfGames].players.push(player);
        gameState[numberOfGames].roundNumber = 0;
        gameState[numberOfGames].currentState = GameStatus.PendingStart;
        return numberOfGames;
    }

    function startGame(uint256 _gameId) public {
        // Randomly assign a member as mafia just when the last player moves the state to start game.
        require(isExistingGame(_gameId), "Invalid game Id");
        require(isPlayerAlreadyInGame(_gameId, msg.sender), "Player not in game");

        gameState[_gameId].players[getPlayerIndex(msg.sender, _gameId)].startGame = true;
        if (allPlayersStartedGame(_gameId)) {
            gameState[_gameId].currentState = GameStatus.MafiaTurn;
            uint idx = randMod(gameState[_gameId].players.length);
            gameState[_gameId].players[idx].role = PlayerRole.Mafia;
        }
    }



    function mafiaKills(string memory _killedVillagerName, uint256 _gameId) public {
        // Ensure both the players are in the relevant game id and the game exists. Ensure the state of the game is apt.
        // Kill the player and alter the state of the game.
        require(isExistingGame(_gameId), "Game id invalid.");
        require(isPlayerMafia(msg.sender, _gameId), "Player is not a Mafia");
        require(isGameStateCorrect(_gameId, GameStatus.MafiaTurn), "Invalid game state");
        uint256 villagerIdx = getPlayerIndexFromName(_killedVillagerName, _gameId);
        bool villagerExist = true;
        if (villagerIdx >= gameState[_gameId].players.length) {
            villagerExist = false;
        }
        require(villagerExist, "Villager does not exist");
        address villagerAddress = gameState[_gameId].players[villagerIdx].id;
        require(!isPlayerMafia(villagerAddress, _gameId), "Invalid Villager");
        uint256 mafiaIdx = getPlayerIndex(msg.sender, _gameId);
        require(isPlayerAlive(mafiaIdx, _gameId), "Msg sender is not alive");
        uint256 idx = getPlayerIndexFromName(_killedVillagerName, _gameId);
        require(isPlayerAlive(villagerIdx, _gameId), "Villager is already dead");

        gameState[_gameId].players[villagerIdx].state = PlayerState.Dead;
        uint256 roundNumber = gameState[_gameId].roundNumber;
        MafiaKillings memory mafiaKilling = MafiaKillings(roundNumber, gameState[_gameId].players[mafiaIdx],
            gameState[_gameId].players[villagerIdx]);
        gameState[_gameId].mafiaKillings.push(mafiaKilling);
        GameStatus previousStatus = gameState[_gameId].currentState;
        if (checkWinningCondition(_gameId)) {
            gameState[_gameId].currentState = GameStatus.GameOver;
        } else {
            gameState[_gameId].currentState = GameStatus.CastingVotes;
        }
        GameStatus status = gameState[_gameId].currentState;
        emit GameStatusUpdated(_gameId, previousStatus, status);
    }

    function castVotes(string memory _votedAgainstName, uint256 _gameId) public {
        // Ensure both the players are in the relevant game id and the game exists. Ensure the state of the game is apt.
        // Mark the vote and store it.
        // If all alive players have voted - make sure to move the state. If the game gets over emit apt event.

        require(isExistingGame(_gameId), "Game id invalid.");
        require(isGameStateCorrect(_gameId, GameStatus.CastingVotes), "Invalid game state");
        uint256 voterIdx = getPlayerIndex(msg.sender, _gameId);
        bool voterExist = true;
        if (voterIdx >= gameState[_gameId].players.length) {
            voterExist = false;
        }
        require(voterExist, "Voter does not exist");
        uint256 votedAgainstIdx = getPlayerIndexFromName(_votedAgainstName, _gameId);
        bool votedAgainstExist = true;
        if (votedAgainstIdx >= gameState[_gameId].players.length) {
            votedAgainstExist = false;
        }
        require(votedAgainstExist, "Invalid voted against");
        require(isPlayerAlive(voterIdx, _gameId), "Voter not alive");
        require(isPlayerAlive(votedAgainstIdx, _gameId), "Voted Against not alive");
        uint256 roundNumber = gameState[_gameId].roundNumber;
        require(checkPlayerAlreadyVoted(_gameId, roundNumber), "Voter has already voted");

        Vote memory vote = Vote(roundNumber, gameState[_gameId].players[voterIdx], gameState[_gameId].players[votedAgainstIdx]);
        gameState[_gameId].votes.push(vote);
        if (checkAllAlivePlayersVoted(_gameId, roundNumber)) {
            uint256 killedPlayerIdx = checkWhoWasVotedOut(_gameId, roundNumber);
            gameState[_gameId].players[killedPlayerIdx].state = PlayerState.Dead;

            GameStatus previousStatus = gameState[_gameId].currentState;
            if (checkWinningCondition(_gameId)) {
                gameState[_gameId].currentState = GameStatus.GameOver;
            } else {
                gameState[_gameId].currentState = GameStatus.MafiaTurn;
                gameState[_gameId].roundNumber++;
            }
            GameStatus status = gameState[_gameId].currentState;
            emit GameStatusUpdated(_gameId, previousStatus, status);
        }
    }



    function addVotingConversation(string memory _votingConversation, uint256 _gameId) public {
        // Ensure game exits. Ensure that the player is part of the game.
        // Add a comment and emit an event.
        require(isExistingGame(_gameId), "Invalid game");
        uint256 playerIdx = getPlayerIndex(msg.sender, _gameId);
        bool playerExist = true;
        if (playerIdx >= gameState[_gameId].players.length) {
            playerExist = false;
        }
        require(playerExist, "Invalid player");
        require(isPlayerAlive(playerIdx, _gameId), "Player is not alive");

        emit VotingConversations(_gameId, msg.sender, _votingConversation);
    }


    function isPlayerMafia(address playerId, uint256 _gameId) private returns (bool) {
        GameState memory gameStateInfo = gameState[_gameId];
        if (gameStateInfo.players[getPlayerIndex(playerId, _gameId)].role == PlayerRole.Mafia) {
            return true;
        }
        return false;
    }

    function isGameStateCorrect(uint256 gameId, GameStatus gameStatus) private returns (bool) {
        GameState memory gameStateInfo = gameState[gameId];
        if (gameStateInfo.currentState == gameStatus) {
            return true;
        }
        return false;
    }

    function isExistingGame(uint256 gameId) private returns (bool) {
        for (uint256 i = 0; i < gameIdList.length; i++) {
            if (gameIdList[i] == gameId) {
                if (gameState[gameId].currentState != GameStatus.GameOver)
                return true;
            }
        }
        return false;
    }

    function isPlayerAlreadyInGame(uint256 _gameId, address _id) private returns (bool) {
        GameState memory gameStateInfo = gameState[_gameId];
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (gameStateInfo.players[i].id == _id) {
                return true;
            }
        }
        return false;
    }


    function allPlayersStartedGame(uint256 _gameId) private returns (bool) {
        GameState memory gameStateInfo = gameState[_gameId];
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (!gameStateInfo.players[i].startGame) {
                return false;
            }
        }
        return true;
    }

    function getPlayerIndex(address _playerId, uint256 _gameId) private returns (uint256) {
        GameState memory gameStateInfo = gameState[_gameId];
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (gameStateInfo.players[i].id == _playerId) {
                return i;
            }
        }
        return gameStateInfo.players.length + 10;
    }

    function getPlayerIndexFromName(string memory _playerName, uint256 _gameId) private returns (uint256) {
        GameState memory gameStateInfo = gameState[_gameId];
        for (uint256 i = 0; i < gameStateInfo.players.length; i++) {
            if (compareString(gameStateInfo.players[i].name, _playerName)) {
                return i;
            }
        }
        return gameStateInfo.players.length + 10;
    }

    function isPlayerAlive(uint256 index, uint256 _gameId) private returns (bool) {
        GameState memory gameStateInfo = gameState[_gameId];
        if (gameStateInfo.players[index].state == PlayerState.Alive) {
            return true;
        }
        return false;
    }


    function checkWinningCondition(uint256 _gameId) private returns (bool) {
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

    function checkAllAlivePlayersVoted(uint256 _gameId, uint256 roundNumber) private returns (bool) {
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

    function checkPlayerAlreadyVoted(uint256 _gameId, uint256 roundNumber) private returns (bool) {
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

    function checkWhoWasVotedOut(uint256 _gameId, uint256 roundNumber) private returns (uint256) {
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

    function randMod(uint _modulus) private returns(uint)
    {
        // increase nonce
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % _modulus;
    }

//    function createProduct(string memory _name, uint _price) public {
//        require(bytes(_name).length > 0);
//        require(_price > 0);
//        // Ensure parameters of product are correct
//        // Create a product
//        // Trigger an event
//        // Increment productCount
//        productCount++;
//        products[productCount] = Product(productCount, _name, _price, msg.sender, false);
//        emit ProductCreated(productCount, _name, _price, msg.sender, false);
//    }
//
//    function purchaseProduct(uint _id) public payable {
//        // Fetch the product
//        // memory creates a deep copy (new copy) different instance from the blockchain
//        Product memory _product = products[_id];
//        // Fetch the owner
//        address payable _seller = _product.owner;
//        // Make sure the product is valid
//        require(_product.id > 0 && _product.id <= productCount); // product has a valid id
//        require(msg.value >= _product.price); // caller account has enough eth
//        require(!_product.purchased); // product is not purchased
//        require(_seller != msg.sender); // seller is not the buyer
//        // Transfer ownership to the buyer
//        _product.owner = msg.sender;
//        _product.purchased = true;
//        products[_id] = _product;
//        // Transfer the ether value to the seller
//        address(_seller).transfer(msg.value);
//        // Emit an event
//        emit ProductPurchased(_id, _product.name, _product.price, msg.sender, true);
//    }
}