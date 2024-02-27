'use strict'

const OperationBase = require('./utils/operation-base')
const AcHandlerState = require('./utils/ac-handler-state')

/**
 * Workload module for starting a session.
 */
class StartSessionWorkloadModule extends OperationBase {
  /**
   * Initializes the instance.
   */
  constructor() {
    super()
  }

  /**
   * Create a pre-configured state representation.
   * @return {AcHandlerState} The state instance.
   */
  createAcHandlerState() {
    return new AcHandlerState(
      this.workerIndex,
      this.resourceUser,
      this.role,
      this.policy,
      this.numberOfPolicies,
      this.tokenId,
      this.token
    )
  }

  /**
   * Assemble TXs for transferring money.
   */
  async submitTransaction() {
    const startSessionArgs = this.acHandlerState.getStartSessionArguments()
    await this.sutAdapter.sendRequests(this.createConnectorRequest('start-session', startSessionArgs))
  }
}

/**
 * Create a new instance of the workload module.
 * @return {WorkloadModuleInterface}
 */
function createWorkloadModule() {
  return new StartSessionWorkloadModule()
}

module.exports.createWorkloadModule = createWorkloadModule
