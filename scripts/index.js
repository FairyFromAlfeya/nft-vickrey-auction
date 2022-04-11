module.exports = async function main (callback) {
  try {
    const NFTVickreyAuction = artifacts.require('NFTVickreyAuction');
    const auction = await NFTVickreyAuction.deployed();

    const start = await auction.start();
    const finish = await auction.finish();

    console.log(`Start: ${start}`);
    console.log(`Finish: ${finish}`);

    callback(0);
  } catch (error) {
    console.error(error);
    callback(1);
  }
};
