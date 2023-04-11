import { config as dotenvconfig } from 'dotenv';
dotenvconfig();

import { HardhatUserConfig, subtask } from 'hardhat/config';

import 'hardhat-abi-exporter';
import 'hardhat-gas-reporter';
import '@typechain/hardhat';
import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-etherscan';

import { TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS } from 'hardhat/builtin-tasks/task-names';

/* 
  Skip contracts/templates files from compilation
*/
subtask(TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS).setAction(async (_, __, runSuper) => {
  const paths = await runSuper();
  return paths.filter((path: string) => !path.includes('contracts/templates'));
});


interface ForkingNetworkRPC {
  mainnet: { url: string };
  avalanche: { url: string };
  polygon: { url: string };
  bsc: { url: string };
  fantom: { url: string };
  arbitrumOne: { url: string };
  optimisticEthereum: { url: string };
  aurora: { url: string };
}

const forkingRPC: ForkingNetworkRPC = {
  mainnet: {
    url: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
  },
  avalanche: {
    url: 'https://api.avax.network/ext/bc/C/rpc',
  },
  polygon: {
    url: 'https://polygon-rpc.com',
  },
  bsc: {
    url: 'https://bsc-dataseed.binance.org/',
  },
  fantom: {
    url: 'https://rpc.fantom.network',
  },
  arbitrumOne: {
    url: 'https://arb1.arbitrum.io/rpc',
  },
  optimisticEthereum: {
    url: 'https://mainnet.optimism.io',
  },
  aurora: {
    url: 'https://mainnet.aurora.dev',
  },
};

const config: HardhatUserConfig = {
  networks: {
    localhost: {
      forking: {
        url: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
        //blockNumber: 15300000,
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
    arbitrumOne: {
      url: 'https://arb1.arbitrum.io/rpc',
      chainId: 42161,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    arbitrumGoerli: {
      url: 'https://goerli-rollup.arbitrum.io/rpc',
      chainId: 421613,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
    },
    optimisticEthereum: {
      url: 'https://mainnet.optimism.io',
      chainId: 10,
      accounts: {
        mnemonic: process.env.MAINNET_PRIVATE_KEY || '',
      },
    },
    optimismGoerli: {
      url: 'https://goerli.optimism.io',
      chainId: 420,
      accounts: {
        mnemonic: process.env.TESTNET_MNEMONIC || '',
      },
    },
    aurora: {
      url: 'https://mainnet.aurora.dev',
      chainId: 1313161554,
      accounts: {
        mnemonic: process.env.TESTNET_MNEMONIC || '',
      },
    },
    auroraTestnet: {
      url: 'https://testnet.aurora.dev',
      chainId: 1313161555,
      accounts: {
        mnemonic: process.env.TESTNET_MNEMONIC || '',
      },
    },
    hardhat: {
      forking: {
        url: forkingRPC[process.env.NETWORK as keyof ForkingNetworkRPC].url,
      },
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.5.16',
      },
      {
        version: '0.7.6',
      },
      {
        version: '0.8.4',
      },
      {
        version: '0.8.9',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
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
