import type { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "ethers";
import type { Deployment } from "hardhat-deploy/types";
import { task } from "hardhat/config";

import { AccessContext__factory } from "../../types";

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
  await tx.wait();
  return policyId;
}

task("setup-role", "Setup role with a sample policy")
  .addParam("contextAddress", "The access context's address")
  .addOptionalParam("policyName", "The policy's name", "Verifier")
  .setAction(async (taskArgs: { policyName: string; contextAddress: string }, hre) => {
    const { getNamedAccounts, deployments, ethers, getChainId } = hre;
    const { deployer } = await getNamedAccounts();
    const chainId = await getChainId();
    const user = `did:pkh:${chainId}:eip155:${deployer}`;
    const signer = await ethers.getSigner(deployer ?? "");
    console.log("setting up role...");
    const policy = await deployments.get(taskArgs.policyName);
    const policyId = await setupRole(taskArgs.contextAddress, signer, { user, policy });
    console.log("setup role success", { policyId });
  });
