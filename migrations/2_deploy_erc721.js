const ERC721PresetMinterPauserAutoId = artifacts.require("ERC721PresetMinterPauserAutoId");

module.exports = async (deployer) => {
  await deployer.deploy(
    ERC721PresetMinterPauserAutoId,
    "My NFT",
    "NFT",
    "https://my-json-server.typicode.com/abcoathup/samplenft/tokens/"
  );
};
