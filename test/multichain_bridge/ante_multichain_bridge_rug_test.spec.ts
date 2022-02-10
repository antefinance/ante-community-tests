import hre from 'hardhat';
const { waffle } = hre;

import { AnteMultichainBridgeRugTest__factory, AnteMultichainBridgeRugTest } from '../../typechain';

import { evmSnapshot, evmRevert } from '../helpers';
import { expect } from 'chai';

describe('AnteMultichainBridgeTest', function () {

    let test: AnteMultichainBridgeRugTest;
    let globalSnapshotId: string;

    before(async () => {
        globalSnapshotId = await evmSnapshot();

        const [deployer] = waffle.provider.getWallets();
        const factory = (await hre.ethers.getContractFactory(
            'AnteMultichainBridgeRugTest',
            deployer
        )) as AnteMultichainBridgeRugTest__factory
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