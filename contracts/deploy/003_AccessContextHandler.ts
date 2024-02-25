import { simpleDeploy } from "../scripts/deploy";
import didRegistryConfig from "./001_DIDRegistry";
import contextConfig from "./002_AccessContext";

const name = "AccessContextHandler";
export default simpleDeploy(name, async function ({ deployments }) {
  const instanceImpl = await deployments.get(contextConfig.id ?? "").then((d) => d.address);
  const didRegistry = await deployments.get(didRegistryConfig.id ?? "").then((d) => d.address);

  return { args: [instanceImpl, didRegistry] };
});
