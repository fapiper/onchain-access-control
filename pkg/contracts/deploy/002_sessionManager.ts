import { simpleDeploy } from "../scripts/deploy";

export default simpleDeploy("SessionManager", {
  args: [
    10 * 60, // maxDuration of session: 10 minutes in unix time
  ],
});
