import { keccak256, toUtf8Bytes } from "ethers";

import { simpleDeploy } from "../scripts/deploy";
import deploySimpleDIDRegistry from "./001_simpleDIDRegistry";

const name = "ACL";
export default simpleDeploy(name, async function ({ deployments }) {
  const didRegistry = await deployments.get(deploySimpleDIDRegistry.id ?? "").then((d) => d.address);
  const systemContext = keccak256(toUtf8Bytes("SYSTEM_CONTEXT"));
  const adminDID = keccak256(toUtf8Bytes("did:web:127.0.0.1:4000"));
  const adminRole = keccak256(toUtf8Bytes("ADMIN"));
  const adminRoleGroup = keccak256(toUtf8Bytes("ADMIN_GROUP"));
  return { args: [didRegistry, systemContext, adminDID, adminRole, adminRoleGroup] };
});
