#!/usr/bin/env bash

# Exit if any subcommand fails
set -e

docker run -ti \
  --rm \
  --name zkauth_setup \
  --mount type=bind,source="$(pwd)"/usecase,target=/app/usecase \
  --mount type=bind,source="$(pwd)"/dev/zokrates/setup.sh,target=/app/setup.sh \
  zokrates/zokrates \
  /bin/bash

bash /app/setup.sh
