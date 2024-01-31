import { simpleDeploy } from "../scripts/deploy";
import didRegistryConfig from "./001_DIDRegistry";
import contextHandlerConfig from "./002_AccessContextHandler";

const name = "SessionRegistry";
export default simpleDeploy(name, async function ({ deployments }) {
  /*
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  const adminDID = `did:pkh:${chainId}:eip155:${deployer}`;
  const adminRole = keccak256(toUtf8Bytes("ADMIN"));
  const adminRoleGroup = keccak256(toUtf8Bytes("ADMIN_GROUP"));
*/

  const contextHandler = await deployments.get(contextHandlerConfig.id ?? "").then((d) => d.address);
  const didRegistry = await deployments.get(didRegistryConfig.id ?? "").then((d) => d.address);

  return { args: [contextHandler, didRegistry] };
});
