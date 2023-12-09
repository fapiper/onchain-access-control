import { simpleDeploy } from "../scripts/deploy";
import simpleDIDRegistry from "./001_simpleDIDRegistry";
import sessionManager from "./002_sessionManager";
import policyRegistry from "./003_policyRegistry";
import acl from "./004_ACL";

const name = "AccessControl";
export default simpleDeploy(name, async function ({ deployments }) {
  const ids = [acl.id, simpleDIDRegistry.id, sessionManager.id, policyRegistry.id]; // note: array order must be considered
  const getAddresses = ids.map((id) => deployments.get(id ?? "").then((d) => d.address));
  const args = await Promise.all(getAddresses);
  return { args };
});
