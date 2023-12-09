import { simpleDeploy } from "../scripts/deploy";
import deploySimpleDIDRegistry from "./001_simpleDIDRegistry";

const name = "ACL";
export default simpleDeploy(name, async function ({ deployments }) {
  const didRegistry = await deployments.get(deploySimpleDIDRegistry.id ?? "").then((d) => d.address);
  return { args: [didRegistry, "system", "admin", "adminRole", "adminRoleGroup"] };
});
