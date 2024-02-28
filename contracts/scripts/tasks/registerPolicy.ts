import type { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "ethers";
import type { Deployment } from "hardhat-deploy/types";
import { task } from "hardhat/config";
import type { HardhatRuntimeEnvironment } from "hardhat/types";

import contextHandlerConfig from "../../deploy/002_AccessContextHandler";
import { AccessContextHandler__factory, AccessContext__factory } from "../../types";
import { simpleDeploy } from "../deploy";

async function createContextInstance(address: string, signer: HardhatEthersSigner, options: { user: string }) {
  const contextHandler = AccessContextHandler__factory.connect(address, signer);
  const id = ethers.id(ethers.randomBytes(32).toString());
  const salt = ethers.randomBytes(20);
  const did = ethers.id(options.user);
  const tx = await contextHandler.createContextInstance(id, salt, did);
  return tx.wait();
}

async function setupRole(address: string, signer: HardhatEthersSigner, options: { user: string; policy: Deployment }) {
  const instance = AccessContext__factory.connect(address, signer);
  const user = options.user;
  const role = ethers.id(`VERIFIER`);
  const policyId = ethers.id(ethers.randomBytes(32).toString());
  const permission = ethers.id(ethers.randomBytes(32).toString());
  const resource = ethers.id(`${user};reports/1`);
  // const operations = new Uint8Array([0, 1]) as unknown as ethers.BigNumberish[];
  const operations: any[] = [ethers.getUint(1)];
  const policyInstance = options.policy.address;
  let policyInterface = new ethers.Interface(options.policy.abi);
  const fragment = policyInterface.getFunction("verifyTx");
  const verify = fragment?.selector ?? "";
  const did = ethers.id(user);
  const tx = await instance["setupRole(bytes32,bytes32,bytes32,bytes32,uint8[],address,bytes4,bytes32)"](
    role,
    policyId,
    permission,
    resource,
    operations,
    policyInstance,
    verify,
    did,
  );
  return tx.wait();
}

async function deployPolicy(hre: HardhatRuntimeEnvironment) {
  const name = "Verifier";
  const { deployments } = hre;

  return simpleDeploy(name)(hre).then(() => deployments.get(name));
}

task("register-policy", "Register a sample policy", async (_, hre) => {
  const { getNamedAccounts, deployments, ethers, getChainId } = hre;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  const user = `did:pkh:${chainId}:eip155:${deployer}`;
  console.log("register policy task for resource owner", user);

  const signer = await ethers.getSigner(deployer ?? "");
  const contextHandlerAddress = await deployments.get(contextHandlerConfig.id ?? "").then((d) => d.address);
  const contextHandler = AccessContextHandler__factory.connect(contextHandlerAddress, signer);

  console.log("creating instance...");
  const createInstanceReceipt = await createContextInstance(contextHandlerAddress, signer, { user });
  console.log("created instance at", createInstanceReceipt?.contractAddress);
  console.log("deploying policy...");
  const policy = await deployPolicy(hre);
  const event = await contextHandler.queryFilter(contextHandler.filters.CreateContextInstance, -1).then((e) => e[0]);
  console.log("setting up role...");
  const role = await setupRole(event?.args[0] ?? "", signer, { user, policy });
  console.log("setup role success", role);
});
