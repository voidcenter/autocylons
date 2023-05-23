const hre = require("hardhat");
const {ethers} = require("hardhat");

let accountId = "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65";
// let accountId = "47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a";
let contractAdd = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
async function joinLobby(gameId) {
    const contractAddress = contractAdd;
    const GameLobby = await hre.ethers.getContractFactory("GameLobby");
    const gameLobby = await GameLobby.attach(contractAddress);

    // Interact with the contract
    const result = await gameLobby.joinLobby("player4", gameId, { from: accountId });
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
    const result = await gameLobby.mafiaKills("player2", gameId, { from: accountId });
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
    const result = await gameLobby.castVotes("player2", gameId, { from: accountId });
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
