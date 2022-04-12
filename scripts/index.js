const { time } = require('@openzeppelin/test-helpers');

function stringToBytes32(value) {
  return web3.utils
    .padRight(
      web3.utils.asciiToHex(value),
      64
    );
}

function createHashedBid(amount, secret) {
  return web3.utils
    .soliditySha3(
      amount,
      stringToBytes32(secret)
    );
}

function timestampToDate(timestamp) {
  return new Date(timestamp * 1000).toISOString();
}

function weiToEther(wei) {
  return web3.utils.fromWei(wei ,'ether');
}

function getAccountBalance(account) {
  return web3.eth
    .getBalance(account)
    .then((balance) => web3.utils.fromWei(balance ,'ether'));
}

module.exports = async function main (callback) {
  try {
    const NFTVickreyAuction = artifacts.require('NFTVickreyAuction');
    const auction = await NFTVickreyAuction.deployed();
    const accounts = await web3.eth.getAccounts();

    console.log(`Auction start at: ${timestampToDate(await auction.startAt())}`);
    console.log(`Auction finish at: ${timestampToDate(await auction.finishAt())}\n`);

    console.log(`Current time: ${timestampToDate(await time.latest())}`);
    await time.increaseTo(1650456583);
    console.log(`New time: ${timestampToDate(await time.latest())}\n`);

    console.log(`Bidder9 balance before bid: ${await getAccountBalance(accounts[9])}`);
    console.log(`Bidder8 balance before bid: ${await getAccountBalance(accounts[8])}`);
    console.log(`Bidder7 balance before bid: ${await getAccountBalance(accounts[7])}`);
    console.log(`Bidder6 balance before bid: ${await getAccountBalance(accounts[6])}\n`);

    await auction.commitBid(createHashedBid(web3.utils.toWei('10'), 'secret9'), { value: web3.utils.toWei('10'), from: accounts[9] });
    await auction.commitBid(createHashedBid(web3.utils.toWei('15'), 'secret8'), { value: web3.utils.toWei('15'), from: accounts[8] });
    await auction.commitBid(createHashedBid(web3.utils.toWei('5'), 'secret7'), { value: web3.utils.toWei('5'), from: accounts[7] });
    await auction.commitBid(createHashedBid(web3.utils.toWei('2'), 'secret6'), { value: web3.utils.toWei('2'), from: accounts[6] });

    console.log(`Bidder9 balance after bid: ${await getAccountBalance(accounts[9])}`);
    console.log(`Bidder8 balance after bid: ${await getAccountBalance(accounts[8])}`);
    console.log(`Bidder7 balance after bid: ${await getAccountBalance(accounts[7])}`);
    console.log(`Bidder6 balance after bid: ${await getAccountBalance(accounts[6])}\n`);

    await time.increaseTo(1650542800);
    console.log(`New time: ${timestampToDate(await time.latest())}\n`);

    await auction.revealBid(web3.utils.toWei('10'), stringToBytes32('secret9'), { from: accounts[9] });
    await auction.revealBid(web3.utils.toWei('15'), stringToBytes32('secret8'), { from: accounts[8] });
    await auction.revealBid(web3.utils.toWei('5'), stringToBytes32('secret7'), { from: accounts[7] });
    await auction.revealBid(web3.utils.toWei('2'), stringToBytes32('secret6'), { from: accounts[6] });

    console.log(`Finished: ${await auction.isFinished()}`);
    console.log(`First place: ${await auction.firstPlaceAddress()} - ${weiToEther(await auction.firstPlaceAmount())}`);
    console.log(`Second place: ${await auction.secondPlaceAddress()} - ${weiToEther(await auction.secondPlaceAmount())}`);
    console.log(`Auction creator balance before finish: ${await getAccountBalance(accounts[0])}\n`);

    await auction.finish();

    console.log(`Finished: ${await auction.isFinished()}`);
    console.log(`Contract balance: ${await getAccountBalance(auction.address)}`)
    console.log(`Auction creator balance after finish: ${await getAccountBalance(accounts[0])}`);
    console.log(`Bidder9 balance after finish: ${await getAccountBalance(accounts[9])}`);
    console.log(`Bidder8 balance after finish: ${await getAccountBalance(accounts[8])}`);
    console.log(`Bidder7 balance after finish: ${await getAccountBalance(accounts[7])}`);
    console.log(`Bidder6 balance after finish: ${await getAccountBalance(accounts[6])}\n`);

    callback(0);
  } catch (error) {
    console.error(error);
    callback(1);
  }
};
