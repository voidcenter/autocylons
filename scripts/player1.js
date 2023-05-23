const hre = require("hardhat");

async function main() {
    // Retrieve the deployed contract instance
    const contractAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
    const GameLobby = await hre.ethers.getContractFactory("GameLobby");
    const gameLobby = await GameLobby.attach(contractAddress);

    // Interact with the contract
    const result = await gameLobby.createGame("player1", { from: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" });
    console.log("Result:", result);
    console.log("Logs:" , await result.wait())
}

// Execute the interaction
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
