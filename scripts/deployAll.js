// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
    const currentTimestampInSeconds = Math.round(Date.now() / 1000);
    const unlockTime = currentTimestampInSeconds + 60;

    const lockedAmount = hre.ethers.utils.parseEther("0.001");

    const GamePlayModel = await hre.ethers.getContractFactory("GamePlayModel");
    const gamePlayModel = await GamePlayModel.deploy();

    await gamePlayModel.deployed();

    console.log(
        `model with ${ethers.utils.formatEther(
            lockedAmount
        )}ETH and unlock model timestamp ${unlockTime} deployed to ${gamePlayModel.address}`
    );



    const GamePlayHelper = await hre.ethers.getContractFactory("GamePlayHelper");
    const gamePlayHelper = await GamePlayHelper.deploy(gamePlayModel.address);

    await gamePlayHelper.deployed();

    console.log(
        `helper with ${ethers.utils.formatEther(
            lockedAmount
        )}ETH and unlock helper timestamp ${unlockTime} deployed to ${gamePlayHelper.address}`
    );



    const GameLobby = await hre.ethers.getContractFactory("GameLobby");
    const gameLobby = await GameLobby.deploy(gamePlayModel.address, gamePlayHelper.address);

    await gameLobby.deployed();

    console.log(
        `lobby with ${ethers.utils.formatEther(
            lockedAmount
        )}ETH and unlock lobby timestamp ${unlockTime} deployed to ${gameLobby.address}`
    );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

//
// (node:79441) ExperimentalWarning: stream/web is an experimental feature. This feature could change at any time
// (Use `node --trace-warnings ...` to show where the warning was created)
// model with 0.001ETH and unlock model timestamp 1684838632 deployed to 0x5FbDB2315678afecb367f032d93F642f64180aa3
// helper with 0.001ETH and unlock helper timestamp 1684838632 deployed to 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
// lobby with 0.001ETH and unlock lobby timestamp 1684838632 deployed to 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
