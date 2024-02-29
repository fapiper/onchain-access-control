import { task } from "hardhat/config";

import { setupRole } from "../../utils";

task("setup-role", "Setup role with a sample policy")
  .addParam("contextAddress", "The access context's address")
  .addOptionalParam("policyName", "The policy's name", "Verifier")
  .setAction(async (taskArgs: { policyName: string; contextAddress: string }, hre) => {
    console.log("setting up role...");
    const result = await setupRole(hre, taskArgs);
    console.log("setup role success", result);
  });
