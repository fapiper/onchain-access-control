#!/bin/bash

code_file=$1
out_dir=$2

# Proving

zokrates compile -i "$code_file" -o out
compiledSize=$(du -kh out | cut -f1)

start=$(date +%s%N)
zokrates compute-witness -i out -o witness -a "${@:3}"
end=$(date +%s%N)
witnessDur=$(echo `expr "$end" - "$start"`)

# Zokrates setup
start=$(date +%s%N)
zokrates setup -i out -p proving.key -v verification.key
end=$(date +%s%N)
setupDur=$(echo `expr "$end" - "$start"`)

provingKeySize=$(du -kh proving.key  | cut -f1)
verificationKeySize=$(du -kh verification.key | cut -f1)

# Verification
zokrates export-verifier -i verification.key -o Verifier.sol

start=$(date +%s%N)
zokrates generate-proof -i out -j proof.json -p proving.key -w witness
end=$(date +%s%N)
proofDur=$(echo `expr "$end" - "$start"`)

echo "time_witness (s),time_setup (s),time_proof (s),size_compiled,size_proving_key,size_verification_key" > result.csv; \
echo "$witnessDur,$setupDur,$proofDur,$compiledSize,$provingKeySize,$verificationKeySize" >> result.csv

cp abi.json proof.json Verifier.sol result.csv "$out_dir"

echo "Required artifacts written to $out_dir"
