require('babel-register');
require('babel-polyfill');
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  // Gnache configuration
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },
    goerli: {
      provider: () => {
        return new HDWalletProvider("invite cheap margin shed story truck arrow tide olympic invest come whip", 'https://goerli.infura.io/v3/870b6f5f4bb6490bbbae37ece59b9b82')
      },
      network_id: '5', // eslint-disable-line camelcase
      gas: 7500000,
      confirmations: 1,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },
  // Smart contract config
  contracts_directory: './src/contracts/',
  contracts_build_directory: './src/abis/',
  // Truffle config
  compilers: {
    solc: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}
