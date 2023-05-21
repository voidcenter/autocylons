const Marketplace = artifacts.require("Game");

module.exports = function(deployer) {
  deployer.deploy(Game);
};
