import { simpleDeploy } from "../scripts/deploy";
import didRegistryConfig from "./001_DIDRegistry";

const name = "AccessContext";
export default simpleDeploy(name, async function ({ deployments, ethers }) {
  const { keccak256, toUtf8Bytes, ZeroAddress } = ethers;

  const sampleInitialOwner = keccak256(toUtf8Bytes("0"));
  const sampleContextId = keccak256(toUtf8Bytes("1"));
  const sampleContextHandler = ZeroAddress;
  const didRegistry = await deployments.get(didRegistryConfig.id ?? "").then((d) => d.address);

  return { args: [sampleInitialOwner, sampleContextId, sampleContextHandler, didRegistry] };
});
