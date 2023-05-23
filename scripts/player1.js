const hre = require("hardhat");
const {ethers} = require("hardhat");

let accountId = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
// let accountId = "ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
let contractAdd = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
async function createGame() {
    const contractAddress = contractAdd;
    const GameLobby = await hre.ethers.getContractFactory("GameLobby");
    const gameLobby = await GameLobby.attach(contractAddress);

    // Interact with the contract
    const result = await gameLobby.createGame("player1", { from: accountId });
    // console.log("Result:", result.value.toNumber());
    let gameId = result.value.toNumber();
    console.log("gameID : ", gameId);
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
    createGame,
    startGame,
    mafiaKills,
    castVotes
};

