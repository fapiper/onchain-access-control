import type { BytesLike } from "ethers";
import { task } from "hardhat/config";

import contextHandlerConfig from "../../deploy/002_AccessContextHandler";
import { AccessContextHandler__factory, type IPolicyVerifier } from "../../types";

task("grant-role", "Grant a role")
  .addParam("context", "The role's and the policies access context id")
  .addParam("policyId", "The policy's id")
  .setAction(async (taskArgs: { context: BytesLike; policyId: BytesLike }, hre) => {
    const { getNamedAccounts, deployments, ethers, getChainId } = hre;
    const { deployer } = await getNamedAccounts();
    const chainId = await getChainId();
    const user = `did:pkh:eip155:${chainId}:${deployer}`;
    const signer = await ethers.getSigner(deployer ?? "");
    const address = await deployments.get(contextHandlerConfig.id ?? "").then((d) => d.address);
    const contextHandler = AccessContextHandler__factory.connect(address, signer);
    const did = ethers.id(user);
    const role = ethers.id(`VERIFIER`);
    const zkVP: IPolicyVerifier.ProofStruct = {
      a: {
        X: "0x192d76d0534ee6501c64d5f1a3c9daf794488a1c59c6211ea95b02c2f4fe651c",
        Y: "0x2a78ba2647a60ca3aef223ab258af4a021cc0f1d14f58f175970c23aee614e27",
      },
      b: {
        X: [
          "0x262d23c44351735bd2f8878b2bcd99b8599cfcde602d933bfa8e4e7318bb8d85",
          "0x11e8f9eee5df1db80d7ec1fe27248c7228e1ce41790c7ff3894c65618a477d77",
        ],
        Y: [
          "0x25da86dc575f43be44963e2fd5e33e854508c7beea21085ef579564428d644e4",
          "0x15f7e64a6ac5058292812ead8ed7561ed35298681721254a753aee23833ce286",
        ],
      },
      c: {
        X: "0x0c54ed11860320a9c0d0b02d12030f0a7d04e1ec2af2ef2c9ebf0165f792f47b",
        Y: "0x0da7a93a3152b4e0c8dc5ffcb8e7674946fa9606838bdf795e40ece797a92f21",
      },
    };

    console.log("granting role...");
    const tx = await contextHandler.grantRole(
      taskArgs.context,
      role,
      did,
      [taskArgs.context],
      [taskArgs.policyId],
      [zkVP],
    );
    await tx.wait();
    console.log("granted role");
  });
