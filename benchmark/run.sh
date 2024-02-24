#docker run \
#    -v $PWD:/hyperledger/caliper/workspace \
#    -e CALIPER_BIND_SUT=ethereum:latest \
#    -e CALIPER_BENCHCONFIG=scenario/simple/config.yaml \
#    -e CALIPER_NETWORKCONFIG=networks/ethereum/1node-clique/networkconfig.json \
#    --name oac-benchmark hyperledger/caliper:0.5.0 launch manager

# Exit on first error, print all commands.
set -e
set -o pipefail

npx caliper launch manager --caliper-bind-sut ethereum:latest --caliper-workspace . --caliper-networkconfig networks/ethereum/1node/ethereum.json --caliper-benchconfig scenario/simple/config.yaml
