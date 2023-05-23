const { ethers } = require('hardhat');

async function getTransactionDetails(txHash) {
    const tx = await ethers.provider.getTransaction("0xab41bff046eaebe4fb8da71e1bb8b00bfcad67ec821dd053563cd2300f9d293d");
    console.log(await ethers.provider)
    console.log("Transaction: ", tx);
}


module.exports = {
    getTransactionDetails
};

// node -e "require('./scripts/verifyTx').getTransactionDetails('0x58248bc3bf82fa7185ebb4d856bb95fb78931dec1c0c3808da1bb8c3d8f92b28')"