'use strict'

/**
 * Class for managing simple account states.
 */
class AcHandlerState {
  /**
   * Initializes the instance.
   */
  constructor(workerIndex, resourceUser, role, policy, numberOfPolicies, tokenId, token) {
    this.context = resourceUser
    this.role = role
    this.policyContexts = Array(numberOfPolicies).fill(resourceUser)
    this.policies = Array(numberOfPolicies).fill(policy)
    this.resourceUser = resourceUser
    this.tokenId = tokenId
    this.token = token
  }

  /**
   * Get the arguments for assigning a role.
   * @returns {object} The assign role arguments.
   */
  getAssignRoleArguments() {
    return {
      context: this.context,
      role: this.role,
      did: this.resourceUser,
      policyContexts: this.policyContexts,
      policies: this.policies,
      args: [],
    }
  }

  /**
   * Get the arguments for starting a session.
   * @returns {object} The account arguments.
   */
  getStartSessionArguments() {
    return {
      did: this.resourceUser,
      tokenId: this.tokenId,
      token: this.token,
    }
  }
}

module.exports = AcHandlerState
