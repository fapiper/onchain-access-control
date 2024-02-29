import type { HardhatRuntimeEnvironment } from "hardhat/types";

import { connectAccessContext, connectAccessContextHandler, connectPolicyVerifier } from "./connect";
import { getCreateAccessContextProps, getPropsFromHre, getSetupRoleProps } from "./props";

export async function createAccessContext(hre: HardhatRuntimeEnvironment) {
  const { user, signer } = await getPropsFromHre(hre);
  const ACHandlerInstance = await connectAccessContextHandler(hre, signer);
  const { id, salt, did } = getCreateAccessContextProps(user);
  const tx = await ACHandlerInstance.createContextInstance(id, salt, did);
  await tx.wait();
  const events = await ACHandlerInstance.queryFilter(ACHandlerInstance.filters.CreateContextInstance, -1);
  const contextAddress = events[0]?.args[0];
  return { id, address: contextAddress, did };
}

export async function setupRole(
  hre: HardhatRuntimeEnvironment,
  { policyName, contextAddress }: { policyName: string; contextAddress: string },
) {
  const { user, signer } = await getPropsFromHre(hre);
  const PolicyVerifierInstance = await connectPolicyVerifier(hre, signer, policyName);
  const ACInstance = await connectAccessContext(hre, signer, contextAddress);
  const { role, policyId, permission, resource, operations, did } = getSetupRoleProps(user);
  const verifier = await PolicyVerifierInstance.getAddress();
  const tx = await ACInstance["setupRole(bytes32,bytes32,bytes32,bytes32,uint8[],address,bytes32)"](
    role,
    policyId,
    permission,
    resource,
    operations,
    verifier,
    did,
  );
  await tx.wait();

  return { policyId };
}
