# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

# Dev tools

check:
	@type "bazel" 2> /dev/null || echo 'Please install bazel'
	@type "docker" 2> /dev/null || echo 'Please install docker'
	@type "jq" 2> /dev/null || echo 'Please install jq'
	@type "abigen" 2> /dev/null || echo 'Please install abigen'

clean:
	@bazel clean

build:
	@bazel build //...

update:
	@make check update-requirements update-manifest update-repos gazelle

update-requirements:
	@bazel run //:requirements.update

update-manifest:
	@bazel run //:gazelle_python_manifest.update

update-repos:
	@bazel run //:gazelle-update-repos

gazelle:
	@bazel run //:gazelle

# Attestation



# Benchmark

bench-run:
	bench-zokrates-run bench-caliper-run

bench-prepare:
	bench-zokrates-prepare bench-caliper-prepare

bench-zokrates-run:
	@bash ./benchmark/zokrates/run.sh

bench-zokrates-cp:
	cp ./benchmark/zokrates/in/1/Verifier.sol ./contracts/src/Policy.sol

bench-zokrates-prepare:
	bench-zokrates-run bench-zokrates-cp

bench-caliper-prepare:
	jq -r '{name: .contractName, gas: 5000000, abi, bytecode}' ./contracts/artifacts/src/AccessContextHandler.sol/AccessContextHandler.json > ./benchmark/src/AccessContextHandler.json

bench-caliper-run:
	@pnpm -C benchmark bench-run

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
