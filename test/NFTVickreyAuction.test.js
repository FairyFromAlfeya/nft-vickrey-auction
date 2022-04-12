const { expect } = require('chai');
const { expectRevert, time } = require('@openzeppelin/test-helpers');
const NFTVickreyAuction = artifacts.require('NFTVickreyAuction');

contract('NFTVickreyAuction', ([ owner, other ]) => {
  beforeEach(async () => {
    const latest = await time.latest();
    this.auction = await NFTVickreyAuction.new(latest + 10, latest + 300);
  });

  it('should throw "Start must be bigger than current timestamp"', () =>
    expectRevert(
      NFTVickreyAuction.new(0, 10000),
      'Returned error: base fee exceeds gas limit -- Reason given: Start must be bigger than current timestamp.',
    )
  );

  it('should throw "Start must be lower than finish"', async () =>
    expectRevert(
      NFTVickreyAuction.new((await time.latest()) + 10, 0),
      'Returned error: base fee exceeds gas limit -- Reason given: Start must be lower than finish.',
    )
  );

  it('should return start and finish', async () =>
    expect(await this.auction.startAt() < await this.auction.finishAt()).to.be.true
  );

  // it('store emits an event', async function () {
  //   const receipt = await this.box.store(value, { from: owner });
  //
  //   // Test that a ValueChanged event was emitted with the new value
  //   expectEvent(receipt, 'ValueChanged', { value: value });
  // });
  //
  // it('non owner cannot store a value', async function () {
  //   // Test a transaction reverts
  //   await expectRevert(
  //     this.box.store(value, { from: other }),
  //     'Ownable: caller is not the owner',
  //   );
  // });
});
