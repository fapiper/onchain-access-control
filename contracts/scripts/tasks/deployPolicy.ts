import { task } from "hardhat/config";

import { simpleDeploy } from "../deploy";

task("deploy-policy", "Deploy a sample policy", async (taskArgs: { name?: string }, hre) => {
  console.log("deploying policy...", taskArgs);
  return simpleDeploy(taskArgs.name ?? "Verifier")(hre);
});
