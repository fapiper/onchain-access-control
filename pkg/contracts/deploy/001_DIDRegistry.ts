import { simpleDeploy } from "../scripts/deploy";

export default simpleDeploy("SimpleDIDRegistry", async function ({ getNamedAccounts, getChainId }) {
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  const initialDIDs = { [`did:pkh:${chainId}:eip155:${deployer}`]: deployer };
  return { args: [Object.keys(initialDIDs), Object.values(initialDIDs)] };
});
