import { config as dotenvconfig } from 'dotenv';
dotenvconfig();

import { HardhatUserConfig } from 'hardhat/config';

import 'hardhat-abi-exporter';
import 'hardhat-gas-reporter';
import '@typechain/hardhat';
import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-etherscan';

const config: HardhatUserConfig = {
  networks: {
    localhost: {
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
        blockNumber: 13089428,
      },
      url: 'http://localhost:8545',
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    hardhat: {
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
        blockNumber: 13743164,
      },
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.7.6',
      },
      {
        version: '0.8.9',
      },
    ],
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY,
  },
  mocha: {
    timeout: 60000,
  },
};

export default config;
