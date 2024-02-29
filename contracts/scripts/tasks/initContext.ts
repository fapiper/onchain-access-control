import { task } from "hardhat/config";

import { createAccessContext } from "../../utils";

task("init-context", "Initialize an access context with policy, role and permission")
  .addOptionalParam("policyName", "The policy's name", "Verifier")
  .setAction(async (taskArgs, hre) => {
    console.log("creating access context...");
    const result = await createAccessContext(hre);
    console.log("created access context", result);
    const contextAddress = result.address;
    await hre.run("deploy-policy", taskArgs);
    await hre.run("setup-role", { ...taskArgs, contextAddress });
  });
