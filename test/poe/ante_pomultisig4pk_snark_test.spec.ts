import hre from 'hardhat';
const { waffle } = hre;

// TODO add the typechain files for YourAnteTest, YourAnteTest__factory
// Note: If you are using an IDE it may warn you that these files are missing.
// This is expected and OK, they will be generated when you run the test command!
import { 
    AntePoMultiSig4PKSnarkTest, 
    AntePoMultiSig4PKSnarkTest__factory,
    PoMultiSig4PKVerifier,
    PoMultiSig4PKVerifier__factory
} from '../../typechain';

import { evmSnapshot, evmRevert, fundSigner, runAsSigner } from '../helpers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';

describe('AntePoMultiSig4PKSnarkTest', function () {
  let test: AntePoMultiSig4PKSnarkTest;
  let verifier: PoMultiSig4PKVerifier;

  let globalSnapshotId: string;

  before(async () => {
    globalSnapshotId = await evmSnapshot();

    const [deployer] = waffle.provider.getWallets();

    // Deploy Verifier
    const verifierFactory = (await hre.ethers.getContractFactory('PoMultiSig4PKVerifier', deployer)) as PoMultiSig4PKVerifier__factory;
    verifier = await verifierFactory.deploy();

    // Deploy Ante Test
    const factory = (await hre.ethers.getContractFactory('AntePoMultiSig4PKSnarkTest', deployer)) as AntePoMultiSig4PKSnarkTest__factory;
    test = await factory.deploy(verifier.address);
    await test.deployed();
  });

  after(async () => {
    await evmRevert(globalSnapshotId);
  });

  it('should currently pass', async () => {
    expect(await test.checkTestPasses()).to.be.true;
  });
  
  it('should fail when proof of private key to address #1 is submitted', async () => {
    const a = [BigNumber.from("0x23d4e140ee36d3e1d6d63f102e2a9ec4c3359a9cc9f753fdf812844ec32599b1"), BigNumber.from("0x2de0b0bc231a4466ea7038655ec3a9c1578fca0537b13ec4d3edb53d08a7f8c1")]
    const b = [[BigNumber.from("0x03cf006616c94673896e5ff0c3369a6d5bfe6978a533ca9ee72f3839251ca604"), BigNumber.from("0x0b4d467049e024d75a71208695d337842f6c2c7bcdd1fc7652d29e1d4866a606")],[BigNumber.from("0x11b58029781056681c3ace55221b4b63f568a6a7c9583ad9771f6050112137e5"), BigNumber.from("0x04a7fb47b61f2509781db9bb279d80eaabe26347ae06b52035e7932446141663")]]
    const c = [BigNumber.from("0x133353a178376747d1204f67ac1026ab6c964b6c12a958d378d94d7c75f2a8fe"), BigNumber.from("0x0160debd4381e3da285f97fb0739fc6bd18753e5a84377e763a3303130e19e05")]
    const input = [BigNumber.from("0x1d3af895fe557fd5504c536fffe695ac850ac003c78015ad85887bfe451ddf93"), BigNumber.from("0x00000000000000000000000066c777464c62f125760f80254257ed8dfccb2921"),BigNumber.from("0x00000000000000000000000009f1ef9171202a72d0854d421244b2361509dced"),BigNumber.from("0x0000000000000000000000003cf58a049f731e5f278304caf98b4699129e6a1d"),BigNumber.from("0x000000000000000000000000877a50594650d4974f42e830dc7940e715e2920c"),BigNumber.from("0x000000000000000000000000000000000000000000000000000000000000002a")]
    await test.setCalldata(
        a as [BigNumber, BigNumber], 
        b as [[BigNumber, BigNumber],[BigNumber, BigNumber]], 
        c as [BigNumber, BigNumber], 
        input as [BigNumber, BigNumber, BigNumber, BigNumber, BigNumber, BigNumber]
    );
    expect(await test.checkTestPasses()).to.be.false;
  });
});
