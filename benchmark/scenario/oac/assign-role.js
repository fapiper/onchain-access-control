'use strict'

const OperationBase = require('./utils/operation-base')
const AcHandlerState = require('./utils/ac-handler-state')

/**
 * Workload module for initializing the SUT with various accounts.
 */
class AssignRoleWorkloadModule extends OperationBase {
  /**
   * Initializes the parameters of the workload.
   */
  constructor() {
    super()
  }

  /**
   * Create an empty state representation.
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
   * Assemble TXs for assigning a role.
   */
  async submitTransaction() {
    const assignRoleArgs = this.acHandlerState.getAssignRoleArguments()
    await this.sutAdapter.sendRequests(this.createConnectorRequest('assign-role', assignRoleArgs))
  }
}

/**
 * Create a new instance of the workload module.
 * @return {WorkloadModuleInterface}
 */
function createWorkloadModule() {
  return new AssignRoleWorkloadModule()
}

module.exports.createWorkloadModule = createWorkloadModule
