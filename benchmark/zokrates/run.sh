#!/bin/bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

docker run -it \
    --rm \
    --mount type=bind,source="$dir",target=/app \
    --name oac_bench_zokrates \
    zokrates/zokrates \
    /app/scripts/monitor.sh
