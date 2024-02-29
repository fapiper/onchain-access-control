import { simpleDeploy } from "../scripts/deploy";
import didRegistryConfig from "./001_DIDRegistry";

const name = "AccessContextHandler";
export default simpleDeploy(name, async function ({ deployments }) {
  const didRegistry = await deployments.get(didRegistryConfig.id ?? "").then((d) => d.address);

  return { args: [didRegistry] };
});
