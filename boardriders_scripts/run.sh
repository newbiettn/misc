#!/bin/bash

S3_ROOT="s3://lexer-client-boardriders/imports"
YEAR="2023"
S3_BUCKET="${S3_ROOT}/${YEAR}"
MONTHS=("02")
DAYS=("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31")
EXPORT_PATH="s3://lexer-client-boardriders/imports/fixing_uncompressed_files"

for month in "${MONTHS[@]}"; do
  for day in ${DAYS[@]}; do
    S3_PATH="${S3_BUCKET}/${month}/${day}/"
    echo "LOG: Checking ${S3_PATH}"
    FILES=$(aws s3 ls "${S3_PATH}" | awk '{print $4}' | grep -v "FULL" | grep -v "V2" | grep -v "EMAIL")
    for file in $FILES; do
      echo "LOG: Downloading ${file}..."
      aws s3 cp "${S3_PATH}${file}" .
      if ! gunzip -t "${file}"; then
        mv "$(basename $file)" "$(basename $file .csv.gz).csv"
	gzip "$(basename $file .csv.gz).csv"  
        echo "LOG: Copying to S3"
        aws s3 cp "$(basename $file)" "${EXPORT_PATH}/${YEAR}/${month}/${day}/" --acl bucket-owner-full-control
      fi
      rm "$(basename $file)"
      echo "--------------------------------------"
    done
  done
done
