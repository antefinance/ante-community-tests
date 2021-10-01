import hre from 'hardhat';
import { Contract } from 'ethers';

export const ONE_ETH = hre.ethers.utils.parseEther('1');
export const HALF_ETH = ONE_ETH.div(2);
export const TWO_ETH = ONE_ETH.mul(2);

export const ONE_BLOCK_DECAY = hre.ethers.BigNumber.from(100e9);
export const VERIFIER_BOUNTY_PCT = 5;
export const CHALLENGER_BLOCK_DELAY = 12;
export const ONE_DAY_IN_SECONDS = 86400;
