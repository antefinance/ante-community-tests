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
        blockNumber: 15300000,
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
    polygonMumbai: {
      url: 'https://rpc-mumbai.maticvigil.com/',
      gasPrice: 225000000000,
      chainId: 80001,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    bsc: {
      url: 'https://bsc-dataseed1.binance.org/',
      chainId: 56,
      gasPrice: 20000000000,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    bscTestnet: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      chainId: 97,
      gasPrice: 20000000000,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    fantom: {
      url: 'https://rpc.fantom.network',
      chainId: 250,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    fantomTestnet: {
      url: 'https://rpc.testnet.fantom.network',
      chainId: 4002,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    arbitrum: {
      url: 'https://arb1.arbitrum.io/rpc',
      chainId: 42161,
      accounts: [process.env.MAINNET_PRIVATE_KEY || ''],
    },
    arbitrumGoerli: {
      url: 'https://rinkeby.arbitrum.io/rpc',
      chainId: 421611,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    hardhat: {
      forking: {
        // Ethereum
        // url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
        // blockNumber: 15300000,
        // Avalanche
        // url: 'https://api.avax.network/ext/bc/C/rpc',
        // Polygon
        // url :'https://polygon-rpc.com',
        // BSC
        // url: 'https://bsc-dataseed.binance.org/',
        // Fantom
        // url: 'https://rpc.fantom.network',
        // Arbitrum
        url: 'https://arb1.arbitrum.io/rpc',
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
