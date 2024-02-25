import { simpleDeploy } from "../scripts/deploy";
import didRegistryConfig from "./001_DIDRegistry";

const name = "AccessContextHandler";
export default simpleDeploy(name, async function ({ deployments, ethers, getChainId, getNamedAccounts }) {
  const { id } = ethers;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  const owner = id(`did:pkh:${chainId}:eip155:${deployer}`);
  // const contextId = keccak256(toUtf8Bytes("1"));
  const didRegistry = await deployments.get(didRegistryConfig.id ?? "").then((d) => d.address);

  return { args: [owner, didRegistry] };
});
