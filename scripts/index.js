module.exports = async function main (callback) {
  try {
    const Box = artifacts.require('Box');
    const box = await Box.deployed();

    await box.store(123);
    const value = await box.retrieve();

    console.log('Box value is', value.toString());

    callback(0);
  } catch (error) {
    console.error(error);
    callback(1);
  }
};
