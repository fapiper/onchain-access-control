import { task } from "hardhat/config";

import { createAccessContext } from "../../utils";

task("create-context", "Create an access context", async (_, hre) => {
  console.log("creating access context...");
  const result = await createAccessContext(hre);
  console.log("created access context", result);
});
