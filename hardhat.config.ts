import { config as dotenvconfig } from 'dotenv';
dotenvconfig();

import { HardhatUserConfig, subtask } from 'hardhat/config';

import 'hardhat-abi-exporter';
import 'hardhat-gas-reporter';
import '@typechain/hardhat';
import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-etherscan';
import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";

import { TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS } from 'hardhat/builtin-tasks/task-names';

/* 
  Skip contracts/templates files from compilation
*/
subtask(TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS).setAction(async (_, hre, runSuper) => {
  const paths = await runSuper();

  const isZkNetwork = ['zkSyncMainnet', 'zkSyncTestnet'].includes(hre.network.name);

  return paths.filter((path: string) =>
    !path.includes('contracts/templates') &&
    (isZkNetwork ? path.includes('contracts/zk') : !path.includes('contracts/zk'))
  );
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
  zkSyncMainnet: { url: string };
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
  zkSyncMainnet: {
    url: 'https://mainnet.era.zksync.io',
  },
};

const config: HardhatUserConfig = {
  networks: {
    localhost: {
      forking: {
        url: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
        blockNumber: 15300000,
      },
      url: 'http://localhost:8545',
      zksync: false,
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    avalanche: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43114,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    avalancheFujiTestnet: {
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43113,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    polygon: {
      url: 'https://polygon-rpc.com',
      gasPrice: 225000000000,
      chainId: 137,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    polygonMumbai: {
      url: 'https://rpc-mumbai.maticvigil.com/',
      gasPrice: 225000000000,
      chainId: 80001,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    bsc: {
      url: 'https://bsc-dataseed1.binance.org/',
      chainId: 56,
      gasPrice: 20000000000,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    bscTestnet: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      chainId: 97,
      gasPrice: 20000000000,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    fantom: {
      url: 'https://rpc.fantom.network',
      chainId: 250,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    fantomTestnet: {
      url: 'https://rpc.testnet.fantom.network',
      chainId: 4002,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    arbitrumOne: {
      url: 'https://arb1.arbitrum.io/rpc',
      chainId: 42161,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    arbitrumGoerli: {
      url: 'https://goerli-rollup.arbitrum.io/rpc',
      chainId: 421613,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: false,
    },
    optimisticEthereum: {
      url: 'https://mainnet.optimism.io',
      chainId: 10,
      accounts: {
        mnemonic: process.env.MAINNET_PRIVATE_KEY || '',
      },
      zksync: false,
    },
    optimismGoerli: {
      url: 'https://goerli.optimism.io',
      chainId: 420,
      accounts: {
        mnemonic: process.env.TESTNET_MNEMONIC || '',
      },
      zksync: false,
    },
    aurora: {
      url: 'https://mainnet.aurora.dev',
      chainId: 1313161554,
      accounts: {
        mnemonic: process.env.TESTNET_MNEMONIC || '',
      },
      zksync: false,
    },
    auroraTestnet: {
      url: 'https://testnet.aurora.dev',
      chainId: 1313161555,
      accounts: {
        mnemonic: process.env.TESTNET_MNEMONIC || '',
      },
      zksync: false,
    },
    zkSyncMainnet: {
      url: 'https://mainnet.era.zksync.io',
      ethNetwork: `https://mainnet.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts: {
        mnemonic: process.env.MNEMONIC || '',
      },
      zksync: true,
    },
    zkSyncTestnet: {
      url: 'https://testnet.era.zksync.dev',
      ethNetwork: `https://goerli.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts: {
        mnemonic: process.env.TESTNET_MNEMONIC || '',
      },
      zksync: true,
    },
    hardhat: {
      forking: {
        url: forkingRPC[process.env.NETWORK as keyof ForkingNetworkRPC].url,
      },
      zksync: ['zkSyncMainnet', 'zkSyncTestnet'].includes(process.env.NETWORK || ''),
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
  zksolc: {
    version: "1.3.10",
    compilerSource: "binary",
    settings: {},
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY,
  },
  mocha: {
    timeout: 60000,
  },
};

export default config;
