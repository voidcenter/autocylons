pragma solidity ^0.5.0;

contract Game {
    enum GameStatus { PendingStart, MafiaTurn, CastingVotes, GameOver }
    string public name;
    uint public productCount = 0;
    mapping(uint => Player) public players;
    mapping(uint256 => GameState) public gameState;
    uint256 numberOfGames;
    uint256[] gameIdList;

    struct Player {
        string name;
        address payable id;
    }

    struct VotingConversation {
        Player player;
        string message;
    }

    struct Vote {
        uint roundNumber;
        Player voter;
        Player votedAgainst;
    }

    struct MafiaKillings {
        uint roundNumber;
        Player mafia;
        Player killedPlayer;
    }

    struct GameState {
        GameStatus currentState;
        Player[] players;
        VotingConversation[] votingConversations;
        Vote[] votes;
        MafiaKillings[] mafiaKillings;
        uint roundNumber;
    }

    constructor() public {
    }

    function joinLobby(Player memory _user, uint memory _gameId) public {
        require(isExistingGame(_gameId), "Invalid game Id");
        require(isPlayerAlreadyInGame(_gameId, _user.id), "Player already in game");

        gameState[_gameId].players.push(_user);
    }

    function createGame(Player memory _user) public returns (uint) {
        Player[] initPlayers;
        initPlayers.push(_user);
        VotingConversation[] memory votingConversations;
        Vote[] memory votes;
        MafiaKillings[] memory mafiaKillings;
        gameState[numberOfGames] = GameState(GameStatus.PendingStart, initPlayers, votingConversations, votes, mafiaKillings, 0);
        numberOfGames++;
        return numberOfGames-1;
    }

    function startGame(Player memory _user, uint256 memory _gameId) public {
        // Randomly assign a member as mafia just when the last player moves the state to start game.
    }

    function mafiaKills(Player memory _mafia, Player memory _killedVillager, uint256 memory _gameId) public {
        // Ensure both the players are in the relevant game id and the game exists. Ensure the state of the game is apt.
        // Kill the player and alter the state of the game.
    }

    function castVotes(Player memory _voter, Player memory _votedAgainst, uint256 _gameId) public {
        // Ensure both the players are in the relevant game id and the game exists. Ensure the state of the game is apt.
        // Mark the vote and store it.
        // If all alive players have voted - make sure to move the state. If the game gets over emit apt event.
    }

    function getAllVotingConversation(uint256 _gameId) public returns (VotingConversation[]) {
        // Ensure game exits. Return all voting conversations related to that game.
    }


    function addVotingConversation(VotingConversation memory _votingConversation, uint256 _gameId, Player _player) public {
        // Ensure game exits. Ensure that the player is part of the game.
        // Add a comment and emit an event.
    }


    function isExistingGame(uint256 gameId) private returns (bool) {
        for (uint256 i = 0; i < gameIdList.length; i++) {
            if (gameIdList[i] == gameId) {
                return true;
            }
        }
        return false;
    }

    function isPlayerAlreadyInGame(uint256 memory _gameId, address memory _id) private returns (bool) {
        GameState gameState = gameState[_gameId];
        for (uint256 i = 0; i < gameState.players.length; i++) {
            if (gameState.players[i].id == _id) {
                return true;
            }
        }
        return false;
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