import { deployAccessContextHandlerFixture } from "./AccessContextHandler.fixture";

describe("AccessContextHandler Unit Tests", async () => {
  before(async function () {
    this.signers = {} as Signers;
    const signers = await ethers.getSigners();
    this.signers.deployer = signers[0];
    this.signers.admin = signers[0];

    this.loadFixture = loadFixture;
  });

  beforeEach(async function () {
    const { instances } = await this.loadFixture(deployAccessContextHandlerFixture);
    this.instances = instances;
  });

  it("Owner creates an access context", async () => {
  });

  it("Owner deploys a PolicyVerifier instance", async () => {

  });

  it("Owner sets up a role and assign policies to it", async () => {

  });

  it("User should succesfully verify a role by presenting its zkVP", async () => {

  });

  it("User should succesfully start a session", async () => {

  });
});
