import hre from 'hardhat';
const { waffle } = hre;

import { AnteAllbridgeRugTest__factory, AnteAllbridgeRugTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteAllbridgeRugTest', function() {
    let test: AnteAllbridgeRugTest;

    let globalSnapshotId: string;

    before(async() => {
        globalSnapshotId = await evmSnapshot();

        const [deployer] = waffle.provider.getWallets();
        const factory = (await hre.ethers.getContractFactory('AnteAllbridgeRugTest', deployer)) as AnteAllbridgeRugTest__factory;
        test = await factory.deploy();
        await test.deployed();
    });

    after(async () => {
        await evmRevert(globalSnapshotId);
    });

    it('should pass', async () => {
        expect(await test.checkTestPasses()).to.be.true;
    });
});