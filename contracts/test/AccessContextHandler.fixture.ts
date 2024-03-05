import type { AccessContextHandler } from "../types";

export async function deployAccessContextHandlerFixture(hre): Promise<{ AccessContextHandlerInstance: AccessContextHandler }> {
  const signers = await hre.ethers.getSigners();
  const admin = signers[0];

  const AccessContextHandlerFactory = await hre.ethers.getContractFactory("AccessContextHandler");
  const AccessContextHandlerInstance = await AccessContextHandlerFactory.connect(admin).deploy();
  await AccessContextHandlerInstance.waitForDeployment();

  return { AccessContextHandlerInstance };
}
