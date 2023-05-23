const hre = require("hardhat");
const {ethers} = require("hardhat");

let accountId = "0x90F79bf6EB2c4f870365E785982E1f101E93b906";
// let accountId = "7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6";
let contractAdd = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
async function joinLobby(gameId) {
    const contractAddress = contractAdd;
    const GameLobby = await hre.ethers.getContractFactory("GameLobby");
    const gameLobby = await GameLobby.attach(contractAddress);

    // Interact with the contract
    const result = await gameLobby.joinLobby("player3", gameId, { from: accountId });
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
