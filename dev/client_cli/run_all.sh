#!/usr/bin/env bash

set -e

dir=$(dirname "$0")

# 1 - Create access context
echo "Executing 1: Create access context..."
res1=$("$dir"/create_access_context.sh)
printf "Finished 1: Create access context - Result:\n%s\n" "$(jq . <<< "$res1")"
sleep 5
# 2 - Register resource
echo "Executing 2: Register resource..."
res2=$("$dir"/register_resource.sh)
printf "Finished 2: Register resource - Result:\n%s\n" "$(jq . <<< "$res2")"
sleep 5
# 3 - Assign role
echo "Executing 3: Assign role..."
res3=$("$dir"/assign_role.sh "$(jq -r '.policy' <<< "$res2")")
printf "Finished 3: Assign role - Result:\n%s\n" "$(jq . <<< "$res3")"
sleep 5
# 4 - Start a session
echo "Executing 4: Start session..."
res4=$("$dir"/start_session.sh)
printf "Finished 4: Start session - Result:\n%s\n" "$(jq . <<< "$res4")"
sleep 5
# 5 - Request the resource
echo "Executing 5: Request resource..."
res5=$("$dir"/request_resource.sh "$(jq -r '.signed_token' <<< "$res4")")
printf "Finished 5: Request resource - Result:\n%s\n" "$res5"
