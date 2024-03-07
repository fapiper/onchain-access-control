'use strict'

/**
 * Class for managing simple account states.
 */
class AcHandlerState {
  /**
   * Initializes the instance.
   */
  constructor(workerIndex, resourceUser, context, role, policy, proof, input, numberOfPolicies, tokenId, token) {
    this.context = context
    this.role = role
    this.policyContexts = Array(numberOfPolicies).fill(context)
    this.policies = Array(numberOfPolicies).fill(policy)
    this.proofs = Array(numberOfPolicies).fill(proof)
    this.inputs = Array(numberOfPolicies).fill(input)
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
      proofs: this.proofs,
      inputs: this.inputs,
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
