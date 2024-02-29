import { task } from "hardhat/config";

import contextHandlerConfig from "../../deploy/002_AccessContextHandler";
import { AccessContextHandler__factory } from "../../types";

task("create-context", "Create an access context", async (_, hre) => {
  const { getNamedAccounts, deployments, ethers, getChainId } = hre;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  const user = `did:pkh:${chainId}:eip155:${deployer}`;
  const signer = await ethers.getSigner(deployer ?? "");
  const address = await deployments.get(contextHandlerConfig.id ?? "").then((d) => d.address);
  const contextHandler = AccessContextHandler__factory.connect(address, signer);
  const id = ethers.id(ethers.randomBytes(32).toString());
  const salt = ethers.randomBytes(20);
  const did = ethers.id(user);

  console.log("creating access context...");
  const tx = await contextHandler.createContextInstance(id, salt, did);
  await tx.wait();
  const event = await contextHandler.queryFilter(contextHandler.filters.CreateContextInstance, -1).then((e) => e[0]);
  const contextAddress = event?.args[0];

  console.log("created access context", { id, address: contextAddress, did });
});
