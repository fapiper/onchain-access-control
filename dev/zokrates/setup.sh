#!/usr/bin/env bash

# Exit if any subcommand fails
set -e

if [ $# -lt 3 ]
  then
    echo "input arguments missing!"
    echo "argument 1: .zok code file"
    echo "argument 2: out dir"
    echo "argument 3: arguments to compute witness for"
    exit 1
fi

if ! [[ -f $1 ]]; then
    echo "[invalid argument 1] file not found!"
fi

code_file=$1
out_dir=$2

# compile
zokrates compile -i "$code_file"

# perform the setup phase
zokrates setup

# execute the program
zokrates compute-witness -a "${@:3}"

# generate a proof of computation
zokrates generate-proof

# export a solidity verifier
zokrates export-verifier

# output: proof.json abi.json verifier.sol

cp abi.json proof.json verifier.sol "$out_dir"

echo "Required artifacts written to $out_dir"
