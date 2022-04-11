const NFTVickreyAuction = artifacts.require("NFTVickreyAuction");

module.exports = function(deployer) {
  deployer.deploy(
    NFTVickreyAuction,
    1650456000,
    1650542400
  );
};
