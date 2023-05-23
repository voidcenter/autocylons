const hre = require("hardhat");
const {ethers} = require("hardhat");

let accountId = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC";
// let accountId = "5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a";
let contractAdd = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
async function joinLobby(gameId) {
    const contractAddress = contractAdd;
    const GameLobby = await hre.ethers.getContractFactory("GameLobby");
    const gameLobby = await GameLobby.attach(contractAddress);

    // Interact with the contract
    const result = await gameLobby.joinLobby("player2", gameId, { from: accountId });
    // console.log("Result:", result.value.toNumber());
    // gameId = result.value.toNumber();
    // console.log("gameID : ", gameId);
    // console.log("Logs:" , await result.wait())
}

async function startGame(gameId) {
    const contractAddress = contractAdd;
    const GameLobby = await hre.ethers.getContractFactory("GameLobby");
    const gameLobby = await GameLobby.attach(contractAddress);

    // Interact with the contract
    const result = await gameLobby.startGame(gameId, { from: accountId });
    // console.log("Result:", result.value.toNumber());
    // gameId = result.value.toNumber();
    // console.log("gameID : ", gameId);
    // console.log("Logs:" , await result.wait())
}

async function mafiaKills(gameId) {
    const contractAddress = contractAdd;
    const GameLobby = await hre.ethers.getContractFactory("GameLobby");
    const gameLobby = await GameLobby.attach(contractAddress);

    // Interact with the contract
    const result = await gameLobby.mafiaKills("player3", gameId, { from: accountId });
    console.log("Result:", result.value.toNumber());
    // gameId = result.value.toNumber();
    // console.log("gameID : ", gameId);
    console.log("Logs:" , await result.wait())
}

async function castVotes(gameId) {
    const contractAddress = contractAdd;
    const GameLobby = await hre.ethers.getContractFactory("GameLobby");
    const gameLobby = await GameLobby.attach(contractAddress);

    // Interact with the contract
    const result = await gameLobby.castVotes("player3", gameId, { from: accountId });
    console.log("Result:", result.value.toNumber());
    // gameId = result.value.toNumber();
    // console.log("gameID : ", gameId);
    console.log("Logs:" , await result.wait())
}

module.exports = {
    joinLobby,
    startGame,
    mafiaKills,
    castVotes
};


// // node -e "require('./scripts/player1').createGame('player1')"
