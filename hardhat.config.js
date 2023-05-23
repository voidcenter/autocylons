require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    goerli: {
      url: "https://goerli.infura.io/v3/870b6f5f4bb6490bbbae37ece59b9b82",
      accounts: ["8a3fe99d99f555fb333b5d724e2cf402b318080e9e7d2c9248037d4fc72e193b"],
    }
  }
};
