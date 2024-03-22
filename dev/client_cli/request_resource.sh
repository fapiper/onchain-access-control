#!/usr/bin/env bash

curl --location --silent 'http://127.0.0.1:4001/static/data/emission_report.csv' --header "Authorization: Bearer $1"
