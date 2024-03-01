# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	@type "bazel" 2> /dev/null || echo 'Please install bazel'
	@type "docker" 2> /dev/null || echo 'Please install docker'
	@type "jq" 2> /dev/null || echo 'Please install jq'
	@type "abigen" 2> /dev/null || echo 'Please install abigen'

python-update-requirements:
	bazel run //:requirements.update

#python-update-gazelle:
#	bazel run //:gazelle_python_manifest.update

# Benchmark

bench-prepare:
	jq -r '{name: .contractName, gas: 5000000, abi, bytecode}' ./contracts/artifacts/src/SimpleDIDRegistry.sol/SimpleDIDRegistry.json > ./benchmark/src/oac/SimpleDIDRegistry.json
	jq -r '{name: .contractName, gas: 5000000, abi, bytecode}' ./contracts/artifacts/src/AccessContextHandler.sol/AccessContextHandler.json > ./benchmark/src/oac/AccessContextHandler.json
	jq -r '{name: .contractName, gas: 5000000, abi, bytecode}' ./contracts/artifacts/src/SessionRegistry.sol/SessionRegistry.json > ./benchmark/src/oac/SessionRegistry.json
	jq -r '{name: .contractName, gas: 5000000, abi, bytecode}' ./contracts/artifacts/src/Policy.sol/Verifier.json > ./benchmark/src/oac/PolicyVerifier.json

bench-run:
	@pnpm -C benchmark bench-run

bench:
	bench-prepare bench-run

# Policy

policy-gen-proof:
	@bash ./dev/zokrates_gen/run.sh /contracts/test/policy/max.zok /contracts/test/policy/out 315555217 1079953207

policy-cp-src:
	cp ./contracts/test/policy/out/verifier.sol ./contracts/src/Policy.sol

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

# Miscellaneous stuff

gazelle-update-repos:
	bazel run //:gazelle-update-repos

gazelle:
	bazel run //:gazelle
