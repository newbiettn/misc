#!/bin/bash

SNAPSHOT_PATHS=("s3://lexer-client-boardriders/deltas/boardriders_group/snapshots/" "s3://lexer-client-boardriders/deltas/boardriders_australia/snapshots/" "s3://lexer-client-boardriders/deltas/boardriders_europe/snapshots/" "s3://lexer-client-boardriders/deltas/boardriders_north_america/snapshots/")

BACKUP_FOLDER="2023/07/05/"
for snapshot_path in "${SNAPSHOT_PATHS[@]}"; do
  echo "================================="
  echo "LOG: Checking ${snapshot_path}"
  FILES=$(aws s3 ls "${snapshot_path}" --recursive | awk '{print $4}' | grep "current" | grep "snapshot")
  backup_path="${snapshot_path}${BACKUP_FOLDER}"
  for file in $FILES; do
    echo "LOG: Backing up ${snapshot_path}$(basename $file)"
    #echo "LOG: New file ${backup_path}$(basename $file)"
    aws s3 cp "s3://lexer-client-boardriders/$file" "${backup_path}" --acl bucket-owner-full-control
  done
done

