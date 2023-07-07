#!/bin/bash

RED='\033[0;31m'
GREEN_LOG='\033[1;94mLOG\033[0m'
NC='\033[0m' # No Color

SNAPSHOT_PATHS=("s3://lexer-client-boardriders/deltas/boardriders_group/snapshots/" "s3://lexer-client-boardriders/deltas/boardriders_australia/snapshots/" "s3://lexer-client-boardriders/deltas/boardriders_europe/snapshots/" "s3://lexer-client-boardriders/deltas/boardriders_north_america/snapshots/")

for snapshot_path in "${SNAPSHOT_PATHS[@]}"; do
  printf "=================================\n"
  printf "${GREEN_LOG}: Checking ${snapshot_path}\n"
  FILES=$(aws s3 ls "${snapshot_path}" --recursive | awk '{print $4}' | grep "current" | grep "snapshot")
  for file in $FILES; do
    filename="$(basename $file)"	  
    printf "${GREEN_LOG}: Removing $file\n" 
    touch "${filename}" # create a temp file
    aws s3 cp "${filename}" "${snapshot_path}" --acl bucket-owner-full-control
    rm "${filename}"
  done
  printf "\n"
done

