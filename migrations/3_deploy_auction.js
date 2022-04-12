const NFTVickreyAuction = artifacts.require("NFTVickreyAuction");

module.exports = async (deployer) => {
  deployer.deploy(
    NFTVickreyAuction,
    1650456000,
    1650542400,
  );
};
