#!/usr/bin/env bash

# Exit if any subcommand fails
set -e

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
read -ra args <<< "$(cat "$(pwd)$3")"

docker run \
    --mount type=bind,source="$(pwd)$1",target=/app/code.zok \
    --mount type=bind,source="$(pwd)$2",target=/app/out \
    --mount type=bind,source="$dir"/monitor.sh,target=/app/monitor.sh \
    --rm \
    zokrates/zokrates \
    /app/monitor.sh \
    /app/code.zok \
    /app/out \
    "${args[@]}"
