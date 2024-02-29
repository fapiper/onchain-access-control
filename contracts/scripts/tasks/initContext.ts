import { task } from "hardhat/config";

import contextHandlerConfig from "../../deploy/002_AccessContextHandler";
import { AccessContextHandler__factory } from "../../types";

task("init-context", "Initialize an access context with policy, role and permission")
  .addOptionalParam("policyName", "The policy's name", "Verifier")
  .setAction(async (taskArgs, hre) => {
    const { deployer } = await hre.getNamedAccounts();
    const address = await hre.deployments.get(contextHandlerConfig.id ?? "").then((d) => d.address);
    const signer = await hre.ethers.getSigner(deployer ?? "");
    const contextHandler = AccessContextHandler__factory.connect(address, signer);
    const runCreateContext = hre.run("create-context");
    const event = await contextHandler.queryFilter(contextHandler.filters.CreateContextInstance, -1).then((e) => e[0]);
    await runCreateContext;
    const contextAddress = event?.args[0];
    await hre.run("deploy-policy", taskArgs);
    await hre.run("setup-role", { contextAddress, ...taskArgs });
  });
