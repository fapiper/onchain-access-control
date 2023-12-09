import { keccak256, toUtf8Bytes } from "ethers";

import { simpleDeploy } from "../scripts/deploy";
import deploySimpleDIDRegistry from "./001_simpleDIDRegistry";

const name = "ACL";
export default simpleDeploy(name, async function ({ deployments, getNamedAccounts, getChainId }) {
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  const didRegistry = await deployments.get(deploySimpleDIDRegistry.id ?? "").then((d) => d.address);

  const systemContext = keccak256(toUtf8Bytes("SYSTEM_CONTEXT"));
  // admin did equals initial did in did registry deployment
  const adminDID = `did:pkh:${chainId}:eip155:${deployer}`;
  const adminRole = keccak256(toUtf8Bytes("ADMIN"));
  const adminRoleGroup = keccak256(toUtf8Bytes("ADMIN_GROUP"));

  return { args: [didRegistry, systemContext, adminDID, adminRole, adminRoleGroup] };
});
