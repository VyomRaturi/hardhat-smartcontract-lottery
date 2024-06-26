require("@nomicfoundation/hardhat-toolbox")
require("hardhat-deploy")
require("dotenv").config()

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY

const SOLC_SETTINGS = {
  optimizer: {
    enabled: true,
    runs: 1_000,
  },
}

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: SOLC_SETTINGS
      },
      // {
      //   version: "0.8.18",
      //   settings: { ...SOLC_SETTINGS, viaIR: true },
      // }
    ],
  },

  defaultNetwork: "hardhat",

  networks: {
    hardhat: {
      chainId: 31337,
      blockConfirmations: 1,
    },

    sepolia: {
      chainId: 11155111,
      url: SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY],
      blockConfirmations: 3
    },
  },

  namedAccounts: {
    deployer: {
      default: 0,
    },
    player1: {
      default: 1,
    },
  },

  gasReporter: {
    enabled: false,
    noColors: true,
    outputFile: "egas-Reports.txt",
    token: "ETH",
    coinmarketcap: COINMARKETCAP_API_KEY,
  },


  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },

  mocha: {
    timeout: 300000,
  },
};
