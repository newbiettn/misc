#!/bin/bash

S3_BUCKET="s3://lexer-client-boardriders/imports/2023"
MONTHS=("03" "04" "05")
DAYS=("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31")

for month in "${MONTHS[@]}"; do
  for day in ${DAYS[@]}; do
    S3_PATH="${S3_BUCKET}/${month}/${day}/"
    echo "LOG: Checking ${S3_PATH}"
    FILES=$(aws s3 ls "${S3_PATH}" | awk '{print $4}' | grep "FULL" | grep "V2" | grep "LOGS")
    for file in $FILES; do
      echo "LOG: Downloading ${file}..."
      aws s3 cp "${S3_PATH}${file}" .
      if ! gunzip -t "${file}"; then
        #echo -e "LOG:\e[32m ${file} is good\e[0m"
      #else
        echo -e "\e[31mERROR: ${file} is broken\e[0m"
        echo "LOG: Copy to unzippable_files.txt"
        echo "${file}" | tee -a unzippable_files.txt
        zcat "${file}" | gzip -c > "$(basename $file .csv.gz)_repaired.csv.gz"
        echo "LOG: Copying to S3"
        aws s3 cp "$(basename $file .csv.gz)_repaired.csv.gz" "${S3_PATH}"
      fi
      rm "$file"
      echo "--------------------------------------"
    done
  done
done
