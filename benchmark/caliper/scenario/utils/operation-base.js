'use strict'

const { WorkloadModuleBase } = require('@hyperledger/caliper-core')
const web3 = require('web3')

const SupportedConnectors = ['ethereum']

const proof = {
  a: {
    X: '0x207e9b1f9a9633d0a9086638aabee33c172ba94c713b3e04b4530cafd5fd042f',
    Y: '0x17af83f93b31de19741bf4a376d1caae08d6e517b2d772156cbe350681cd2e82',
  },
  b: {
    X: [
      '0x1292827c3f09eea38778bd54da04415036b1e206eee4bd8877a8ab197ccfd5c4',
      '0x25e3c901e4f17dee4a743efefa33983e07734ce1695f787c4f7f94d9cd94726f',
    ],
    Y: [
      '0x149aa0c72acda7ec484877b1582d74612def5025bbcd7fbfbfb80327ea8f4792',
      '0x1382e3e087ab8b4297d3214f390e6099874e09db2aa15cf33b53afb6f63f2ce7',
    ],
  },
  c: {
    X: '0x0fa1fef03502c56dafd34c9e08e2dc089a622667d77133ba380cab0c98c20598',
    Y: '0x044b495dafb8e35138cde24fa9749f4a91f99104f19770742e29b7dbf798382a',
  },
}

const input = [
  '0x000000000000000000000000000000000000000000000000000000000131c9a5',
  '0x196ad888b3d5184eec5967943eeb4d211aa41c0e68f9634cf5a14a91f9df206d',
  '0x24d0fafb29a809fa7a55a6aacc57f78d794721aca594d7a35089d0261f3d1572',
  '0x00000000000000000000000000000000000000000000000000000000b722fe4f',
  '0x00000000000000000000000000000000000000000000000000000000a415b2ba',
  '0x00000000000000000000000000000000000000000000000000000000d444d8a9',
  '0x0000000000000000000000000000000000000000000000000000000090958d4e',
  '0x000000000000000000000000000000000000000000000000000000007a775c92',
  '0x000000000000000000000000000000000000000000000000000000001fd2e756',
  '0x000000000000000000000000000000000000000000000000000000000df8c0e5',
  '0x00000000000000000000000000000000000000000000000000000000374e9b15',
  '0x00000000000000000000000000000000000000000000000000000000b722fe4f',
  '0x00000000000000000000000000000000000000000000000000000000a415b2ba',
  '0x00000000000000000000000000000000000000000000000000000000d444d8a9',
  '0x0000000000000000000000000000000000000000000000000000000090958d4e',
  '0x000000000000000000000000000000000000000000000000000000007a775c92',
  '0x000000000000000000000000000000000000000000000000000000001fd2e756',
  '0x000000000000000000000000000000000000000000000000000000000df8c0e5',
  '0x00000000000000000000000000000000000000000000000000000000374e9b15',
  '0x0000000000000000000000000000000000000000000000000000000000000000',
]

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
    this.proof = proof
    this.input = input
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
