#!/usr/bin/env bash

# Exit if any subcommand fails
set -e

if [ $# -lt 1 ]
  then
    echo "input arguments missing!"
    echo "argument 1: signed session token"
    exit 1
fi

curl http://127.0.0.1:4001/static/data/emission_report.csv
   -H "Accept: application/json"
   -H "Authorization: Bearer {$1}"
