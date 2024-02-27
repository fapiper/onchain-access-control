'use strict'

const EthereumDeploymentArgsConnector = require('./EthereumDeploymentArgsConnector')

/**
 * Constructs an Ethereum adapter.
 * @param {number} workerIndex The zero-based index of the worker who wants to create an adapter instance. -1 for the manager process.
 * @return {Promise<ConnectorBase> | ConnectorBase} The initialized adapter instance.
 * @async
 */
async function connectorFactory(workerIndex) {
  return new EthereumDeploymentArgsConnector(workerIndex, 'ethereum')
}

module.exports.ConnectorFactory = connectorFactory
