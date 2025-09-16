#!/bin/bash

# URL of the GreenGenes database
URL="https://data.qiime2.org/2021.4/common/gg_13_8_otus.tar.gz"

# Name of the downloaded file
DB_NAME="gg_13_8_otus.tar.gz"

# Directory to extract the database
DB_DIR="gg_13_8_otus"

# Download the GreenGenes database
echo " Downloading GreenGenes database..."
wget -q $URL -O $DB_NAME

# Extract the GreenGenes database
echo " Extracting GreenGenes database..."
tar -xzvf $DB_NAME -C $DB_DIR

# Remove the tar.gz file after extraction
rm $DB_NAME

echo "GreenGenes database has been downloaded and extracted to $DB_DIR."

