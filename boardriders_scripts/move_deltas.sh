#!/bin/bash

S3_BUCKET="s3://lexer-client-boardriders/customerapi/us-identity-history/persist"
BRAND_REGION=("apac" "eu" "na")
BRAND=("billabong" "rvca" "roxy" "quicksilver" "element" "dcshoes")

for br in ${BRAND_REGION[@]}; do
  for b in ${BRAND[@]}; do
    DELTAS=$(aws s3 ls "${S3_BUCKET}/" | awk '{print $NF}' | grep "$br" | grep "$b")
    for d in $DELTAS; do
      echo "LOG: Processing $br $b..."
      echo "LOG: $d"
      #echo "${S3_BUCKET}/${d::-1}"
      aws s3 cp "${S3_BUCKET}/${d::-1}" "${S3_BUCKET}/brand_region=$br/brand=$b/$d" --recursive --acl bucket-owner-full-control
      done
  done
done
