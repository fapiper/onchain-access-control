import { simpleDeploy } from "../scripts/deploy";

export default simpleDeploy("SimpleDIDRegistry", async function ({ ethers, getNamedAccounts, getChainId }) {
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  const initialDIDs = { [ethers.id(`did:pkh:eip155:${chainId}:${deployer}`)]: deployer };
  return { args: [Object.keys(initialDIDs), Object.values(initialDIDs)] };
});
