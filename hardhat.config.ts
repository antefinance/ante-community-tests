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
        blockNumber: 14677216,
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
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    avalanche: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43114,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    avalancheFujiTestnet: {
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43113,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    polygon: {
      url: 'https://polygon-rpc.com',
      gasPrice: 225000000000,
      chainId: 137,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    mumbai: {
      url: 'https://rpc-mumbai.maticvigil.com/',
      gasPrice: 225000000000,
      chainId: 80001,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    hardhat: {
      forking: {
        url: `https://polygon-rpc.com`,
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
      {
        version: '0.8.4',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.5.16',
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
