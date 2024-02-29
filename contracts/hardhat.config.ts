import "@nomicfoundation/hardhat-toolbox";
import { config as dotenvConfig } from "dotenv";
import "hardhat-deploy";
import type { HardhatUserConfig } from "hardhat/config";
import type { NetworkUserConfig } from "hardhat/types";
import { resolve } from "path";

import "./scripts/tasks/createContext";
import "./scripts/tasks/deployPolicy";
import "./scripts/tasks/grantRole";
import "./scripts/tasks/initContext";
import "./scripts/tasks/setupRole";

const dotenvConfigPath: string = process.env["DOTENV_CONFIG_PATH"] || "./.env";
dotenvConfig({ path: resolve(__dirname, dotenvConfigPath) });

// Ensure that we have all the environment variables we need.
const mnemonic: string | undefined = process.env["MNEMONIC"];
if (!mnemonic) {
  throw new Error("Please set your MNEMONIC in a .env file");
}

const infuraApiKey: string | undefined = process.env["INFURA_API_KEY"];
if (!infuraApiKey) {
  throw new Error("Please set your INFURA_API_KEY in a .env file");
}

const chainIds = {
  hardhat: 31337,
  sepolia: 11155111,
};

function getChainConfig(chain: keyof typeof chainIds): NetworkUserConfig {
  let jsonRpcUrl = "https://" + chain + ".infura.io/v3/" + infuraApiKey;

  return {
    accounts: {
      mnemonic: mnemonic!,
    },
    chainId: chainIds[chain],
    url: jsonRpcUrl,
  };
}

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: { default: 0, sepolia: "0xd231120Eea6201B142b4048cf6C86BaC2A0655D2" },
  },
  etherscan: {
    apiKey: {
      sepolia: process.env["ETHERSCAN_API_KEY"] || "",
    },
  },
  gasReporter: {
    currency: "EUR",
    enabled: !!process.env["REPORT_GAS"],
    excludeContracts: [],
    src: "./src",
  },
  networks: {
    hardhat: {
      chainId: chainIds.hardhat,
    },
    sepolia: getChainConfig("sepolia"),
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./src",
    tests: "./test",
  },
  solidity: {
    version: "0.8.20",
    settings: {
      metadata: {
        // Not including the metadata hash
        // https://github.com/paulrberg/hardhat-template/issues/31
        bytecodeHash: "none",
      },
      // Disable the optimizer when debugging
      // https://hardhat.org/hardhat-network/#solidity-optimizer-support
      optimizer: {
        enabled: true,
        runs: 800,
      },
    },
  },
  typechain: {
    outDir: "types",
    target: "ethers-v6",
  },
};

export default config;
