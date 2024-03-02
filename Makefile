# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

# Dev tools

dev-update:
	@make dev-check dev-update-requirements dev-update-manifest dev-update-repos dev-gazelle

dev-check:
	@type "bazel" 2> /dev/null || echo 'Please install bazel'
	@type "docker" 2> /dev/null || echo 'Please install docker'
	@type "jq" 2> /dev/null || echo 'Please install jq'
	@type "abigen" 2> /dev/null || echo 'Please install abigen'

dev-update-requirements:
	@bazel run //:requirements.update

dev-update-manifest:
	@bazel run //:gazelle_python_manifest.update

dev-update-repos:
	@bazel run //:gazelle-update-repos

dev-gazelle:
	@bazel run //:gazelle

# Attestation



# Benchmark

bench-prepare:
	jq -r '{name: .contractName, gas: 5000000, abi, bytecode}' ./contracts/artifacts/src/SimpleDIDRegistry.sol/SimpleDIDRegistry.json > ./benchmark/src/oac/SimpleDIDRegistry.json
	jq -r '{name: .contractName, gas: 5000000, abi, bytecode}' ./contracts/artifacts/src/AccessContextHandler.sol/AccessContextHandler.json > ./benchmark/src/oac/AccessContextHandler.json
	jq -r '{name: .contractName, gas: 5000000, abi, bytecode}' ./contracts/artifacts/src/SessionRegistry.sol/SessionRegistry.json > ./benchmark/src/oac/SessionRegistry.json
	jq -r '{name: .contractName, gas: 5000000, abi, bytecode}' ./contracts/artifacts/src/Policy.sol/Verifier.json > ./benchmark/src/oac/PolicyVerifier.json

bench-run:
	@pnpm -C benchmark bench-run

bench:
	policy-prepare bench-prepare bench-run

# Policy

policy-gen-proof:
	@bash ./benchmark/zokrates/run.sh /contracts/test/policy/min.zok /benchmark/zokrates/min /dev/attestation/witness/min.txt

policy-cp-src:
	cp ./benchmark/zokrates/min/Verifier.sol ./contracts/src/Policy.sol

policy-prepare:
	policy-gen-proof policy-cp-verifier

# Contracts

# TODO prepend contract compilation
contracts:
	abi-process abi-gen

abi-process:
	jq -r '.abi' ./contracts/artifacts/src/AccessContext.sol/AccessContext.json > ./core/contracts/abi/AccessContext.abi
	jq -r '.abi' ./contracts/artifacts/src/AccessContextHandler.sol/AccessContextHandler.json > ./core/contracts/abi/AccessContextHandler.abi
	jq -r '.abi' ./contracts/artifacts/src/SessionRegistry.sol/SessionRegistry.json > ./core/contracts/abi/SessionRegistry.abi
	jq -r '.abi' ./contracts/artifacts/src/SimpleDIDRegistry.sol/SimpleDIDRegistry.json > ./core/contracts/abi/SimpleDIDRegistry.abi

abi-gen:
	abigen --abi=./core/contracts/abi/AccessContext.abi --pkg=contracts --type=AccessContext > ./core/contracts/AccessContext.go
	abigen --abi=./core/contracts/abi/AccessContextHandler.abi --pkg=contracts --type=AccessContextHandler > ./core/contracts/AccessContextHandler.go
	abigen --abi=./core/contracts/abi/SessionRegistry.abi --pkg=contracts --type=SessionRegistry > ./core/contracts/SessionRegistry.go
	abigen --abi=./core/contracts/abi/SimpleDIDRegistry.abi --pkg=contracts --type=SimpleDIDRegistry > ./core/contracts/SimpleDIDRegistry.go
