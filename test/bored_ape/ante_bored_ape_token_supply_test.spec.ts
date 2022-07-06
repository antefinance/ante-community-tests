import hre from 'hardhat';
const { waffle } = hre;

// TODO: Fix this IERC721 import not working
import { IERC721, AnteBoredApeMaxSupplyTest, AnteBoredApeMaxSupplyTest__factory } from '../../typechain';

import { evmSnapshot, evmRevert, runAsSigner } from '../helpers';
import { expect } from 'chai';

describe('AnteBoredApeMaxSupplyTest', function () {
  let test: AnteBoredApeMaxSupplyTest;
  let bayc: IERC721;
  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();
    bayc = <IERC721>(
      await hre.ethers.getContractAt(
        '@openzeppelin/contracts/token/ERC721/IERC721.sol:IERC721',
        '0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D'
      )
    );
    const [deployer] = waffle.provider.getWallets();
    const factory = (await hre.ethers.getContractFactory(
      'AnteBoredApeMaxSupplyTest',
      deployer
    )) as AnteBoredApeMaxSupplyTest__factory;
    test = await factory.deploy();
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });

  it('should fail if Yuga Labs reserves apes', async () => {
    const BAYC_DEPLOYER_ADDRESS = '0xaBA7161A7fb69c88e16ED9f455CE62B791EE4D03';

    await runAsSigner(BAYC_DEPLOYER_ADDRESS, async () => {
      const yugaLabs = await hre.ethers.getSigner(BAYC_DEPLOYER_ADDRESS);

      // mint 30 new apes for yuga, bringing total above MAX
      await bayc.connect(yugaLabs).reserveApes();
    });
    expect(await test.checkTestPasses()).to.be.false;
  });
});
