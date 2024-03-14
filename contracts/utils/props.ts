import { ethers } from "ethers";
import type { HardhatRuntimeEnvironment } from "hardhat/types";

export async function getPropsFromHre(hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, ethers, getChainId } = hre;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  const user = `did:pkh:eip155:${chainId}:${deployer}`;
  const signer = await ethers.getSigner(deployer ?? "");
  return { user, signer, deployments, ethers };
}

export function getCreateAccessContextProps(user: string) {
  const id = ethers.id(user);
  const salt = ethers.randomBytes(20);
  const did = ethers.id(user);
  return { id, salt, did };
}

export function getSetupRoleProps(user: string) {
  const role = ethers.id(`ROLE_VERIFICATION_BODY`);
  const policyId = ethers.id(ethers.randomBytes(32).toString());
  const permission = ethers.id(ethers.randomBytes(32).toString());
  const resource = ethers.id(`${user};reports/1`);
  const operations: any[] = [ethers.getUint(1)];
  const did = ethers.id(user);
  return { role, policyId, permission, resource, operations, did };
}
