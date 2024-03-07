import hre from "hardhat"
import { getPropsFromHre } from "../utils/props";
import { connectAccessContextHandler, connectPolicyVerifier } from "../utils/connect";
export async function deployAccessContextHandlerFixture() {
  const { user, signer } = await getPropsFromHre(hre);
  const AccessContextHandler = await connectAccessContextHandler(hre, signer);
  const PolicyVerifier = await connectPolicyVerifier(hre, signer, "Verifier");

  return { user, instances:{PolicyVerifier, AccessContextHandler}, };
}
