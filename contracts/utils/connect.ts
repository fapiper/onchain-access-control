import type { ethers } from "ethers";
import type { HardhatRuntimeEnvironment } from "hardhat/types";

import contextHandlerConfig from "../deploy/002_AccessContextHandler";
import { AccessContextHandler__factory, AccessContext__factory, Verifier__factory } from "../types";

export async function connectAccessContextHandler(hre: HardhatRuntimeEnvironment, signer: ethers.Signer) {
  const address = await hre.deployments.get(contextHandlerConfig.id ?? "").then((d) => d.address);
  return AccessContextHandler__factory.connect(address, signer);
}

export async function connectAccessContext(_: HardhatRuntimeEnvironment, signer: ethers.Signer, address: string) {
  return AccessContext__factory.connect(address, signer);
}

export async function connectPolicyVerifier(hre: HardhatRuntimeEnvironment, signer: ethers.Signer, name: string) {
  const address = await hre.deployments.get(name).then((d) => d.address);
  return Verifier__factory.connect(address, signer);
}
