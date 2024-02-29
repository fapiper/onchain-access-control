import { task } from "hardhat/config";

import { simpleDeploy } from "../deploy";

task("deploy-policy", "Deploy a sample policy")
  .addOptionalParam("policyName", "The policy's name", "Verifier")
  .setAction(async (taskArgs: { policyName: string }, hre) => simpleDeploy(taskArgs.policyName)(hre));
