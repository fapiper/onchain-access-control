#!/usr/bin/env bash

# Exit if any subcommand fails
set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

docker run -ti \
    --mount type=bind,source="$(pwd)$1",target=/app/code.zok \
    --mount type=bind,source="$(pwd)$2",target=/app/out \
    --mount type=bind,source="$script_dir"/gen_proof.sh,target=/app/gen_proof.sh \
    --rm \
    zokrates/zokrates \
    /app/gen_proof.sh \
    /app/code.zok \
    /app/out \
    "${@:3}"
