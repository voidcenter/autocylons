require('babel-register');
require('babel-polyfill');

module.exports = {
  // Gnache configuration
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
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
