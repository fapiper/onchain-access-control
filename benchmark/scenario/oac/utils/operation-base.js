'use strict'

const { WorkloadModuleBase } = require('@hyperledger/caliper-core')
const web3 = require('web3')

const SupportedConnectors = ['ethereum']

const proof = {
  a: {
    X: '0x192d76d0534ee6501c64d5f1a3c9daf794488a1c59c6211ea95b02c2f4fe651c',
    Y: '0x2a78ba2647a60ca3aef223ab258af4a021cc0f1d14f58f175970c23aee614e27',
  },
  b: {
    X: [
      '0x262d23c44351735bd2f8878b2bcd99b8599cfcde602d933bfa8e4e7318bb8d85',
      '0x11e8f9eee5df1db80d7ec1fe27248c7228e1ce41790c7ff3894c65618a477d77',
    ],
    Y: [
      '0x25da86dc575f43be44963e2fd5e33e854508c7beea21085ef579564428d644e4',
      '0x15f7e64a6ac5058292812ead8ed7561ed35298681721254a753aee23833ce286',
    ],
  },
  c: {
    X: '0x0c54ed11860320a9c0d0b02d12030f0a7d04e1ec2af2ef2c9ebf0165f792f47b',
    Y: '0x0da7a93a3152b4e0c8dc5ffcb8e7674946fa9606838bdf795e40ece797a92f21',
  },
}

/**
 * Base class for simple operations.
 */
class OperationBase extends WorkloadModuleBase {
  /**
   * Initializes the base class.
   */
  constructor() {
    super()
  }

  /**
   * Initialize the workload module with the given parameters.
   * @param {number} workerIndex The 0-based index of the worker instantiating the workload module.
   * @param {number} totalWorkers The total number of workers participating in the round.
   * @param {number} roundIndex The 0-based index of the currently executing round.
   * @param {Object} roundArguments The user-provided arguments for the round from the benchmark configuration file.
   * @param {ConnectorBase} sutAdapter The adapter of the underlying SUT.
   * @param {Object} sutContext The custom context object provided by the SUT adapter.
   * @async
   */
  async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
    await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext)

    this.assertConnectorType()
    this.assertSetting('resourceUser')
    this.assertSetting('context')
    this.assertSetting('role')
    this.assertSetting('policy')
    this.assertSetting('numberOfPolicies')

    this.resourceUser = web3.utils.keccak256(this.roundArguments.resourceUser)
    this.context = this.roundArguments.context
    this.role = web3.utils.keccak256(this.roundArguments.role)
    this.policy = this.roundArguments.policy
    this.zkVP = proof
    this.numberOfPolicies = this.roundArguments.numberOfPolicies
    this.tokenId = web3.utils.randomHex(32)
    this.token = web3.utils.keccak256('EXAMPLE_TOKEN')

    this.acHandlerState = this.createAcHandlerState()
  }

  /**
   * Performs the operation mode-specific initialization.
   * @return {AcHandlerState} the initialized AcHandlerState instance.
   * @protected
   */
  createAcHandlerState() {
    throw new Error('Simple workload error: "createAcHandlerState" must be overridden in derived classes')
  }

  /**
   * Assert that the used connector type is supported. Only Fabric is supported currently.
   * @protected
   */
  assertConnectorType() {
    this.connectorType = this.sutAdapter.getType()
    if (!SupportedConnectors.includes(this.connectorType)) {
      throw new Error(`Connector type ${this.connectorType} is not supported by the benchmark`)
    }
  }

  /**
   * Assert that a given setting is present among the arguments.
   * @param {string} settingName The name of the setting.
   * @protected
   */
  assertSetting(settingName) {
    if (!this.roundArguments.hasOwnProperty(settingName)) {
      throw new Error(
        `Simple workload error: module setting "${settingName}" is missing from the benchmark configuration file`
      )
    }
  }

  /**
   * Assemble a connector-specific request from the business parameters.
   * @param {string} operation The name of the operation to invoke.
   * @param {object} args The object containing the arguments.
   * @return {object} The connector-specific request.
   * @protected
   */
  createConnectorRequest(operation, args) {
    switch (this.connectorType) {
      case 'ethereum':
        return this._createEthereumConnectorRequest(operation, args)
      default:
        // this shouldn't happen
        throw new Error(`Connector type ${this.connectorType} is not supported by the benchmark`)
    }
  }

  /**
   * Assemble an Ethereum-specific request from the business parameters.
   * @param {string} operation The name of the operation to invoke.
   * @param {object} args The object containing the arguments.
   * @return {object} The Ethereum-specific request.
   * @private
   */
  _createEthereumConnectorRequest(operation, args) {
    return {
      contract: 'AccessContextHandler',
      verb: operation,
      args: Object.keys(args).map((k) => args[k]),
      readOnly: false,
    }
  }
}

module.exports = OperationBase
