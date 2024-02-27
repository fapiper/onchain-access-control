'use strict'

const EthereumConnector = require('@hyperledger/caliper-ethereum/lib/ethereum-connector')

/**
 * @typedef {Object} EthereumInvoke
 *
 * @property {string} contract Required. The name of the smart contract
 * @property {string} verb Required. The name of the smart contract function
 * @property {string} args Required. Arguments of the smart contract function in the order in which they are defined
 * @property {boolean} readOnly Optional. If method to call is a view.
 */

/**
 * Extends {BlockchainConnector} for a web3 Ethereum backend.
 */
class EthereumDeploymentArgsConnector extends EthereumConnector {
  /**
   * Create a new instance of the {Ethereum} class.
   * @param {number} workerIndex The zero-based index of the worker who wants to create an adapter instance. -1 for the manager process.
   * @param {string} bcType The target SUT type
   */
  constructor(workerIndex, bcType) {
    super(workerIndex, bcType)
  }

  /**
   * Deploy smart contracts specified in the network configuration file.
   * @return {object} Promise execution for all the contract creations.
   */
  async installSmartContract() {
    return super.installSmartContract()
  }
}

module.exports = EthereumDeploymentArgsConnector
