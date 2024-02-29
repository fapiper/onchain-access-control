import type { BytesLike } from "ethers";
import { task } from "hardhat/config";

import contextHandlerConfig from "../../deploy/002_AccessContextHandler";
import { AccessContextHandler__factory } from "../../types";

task("grant-role", "Grant a role")
  .addParam("context", "The role's and the policies access context id")
  .addParam("policy", "The policy's id")
  .setAction(async (taskArgs: { context: BytesLike; policy: BytesLike }, hre) => {
    const { getNamedAccounts, deployments, ethers, getChainId } = hre;
    const { deployer } = await getNamedAccounts();
    const chainId = await getChainId();
    const user = `did:pkh:${chainId}:eip155:${deployer}`;
    const signer = await ethers.getSigner(deployer ?? "");
    const address = await deployments.get(contextHandlerConfig.id ?? "").then((d) => d.address);
    const contextHandler = AccessContextHandler__factory.connect(address, signer);
    const did = ethers.id(user);
    const role = ethers.id(`VERIFIER`);

    console.log("granting role...");
    const tx = await contextHandler.grantRole(taskArgs.context, role, did, [taskArgs.context], [taskArgs.policy], []);
    await tx.wait();
    console.log("granted role");
  });
