#!/bin/bash

# --- Configure AWS CLI credentials from environment variables ---
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_DEFAULT_REGION" ]; then
  echo "AWS credentials or region not set in environment variables. Exiting..."
  exit 1
fi

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_DEFAULT_REGION"
echo "AWS CLI configured using environment variables."

set -e

# === CONFIGURATION ===
TERRAFORM_VAR_FILE="terraform.tfvars"
DATASET_URL="https://zenodo.org/record/5377831/files/flightlist_20190101_20190131.csv.gz?download=1"
LOCAL_FILE="flight_data.csv.gz"
TEMP_CSV="flight_data.csv"
SMALL_CSV="flight_data_small.csv"
SMALL_GZ="flight_data_small.csv.gz"
TARGET_SIZE_MB=5

# Extract bucket name from .tfvars file
BUCKET_NAME=$(grep bucket_name "$TERRAFORM_VAR_FILE" | awk -F\" '{print $2}')

# === TERRAFORM DEPLOYMENT ===
echo "Initializing Terraform..."
terraform init

echo "Planning infrastructure changes..."
terraform plan -var-file="$TERRAFORM_VAR_FILE"

echo "Applying infrastructure changes..."
terraform apply -var-file="$TERRAFORM_VAR_FILE" -auto-approve

# === DOWNLOAD ORIGINAL DATASET ===
echo "Downloading dataset from OpenSky Network..."
curl -L "$DATASET_URL" -o "$LOCAL_FILE"

# === EXTRACT HEADER AND ENOUGH ROWS TO MAKE ~5MB FILE ===
echo "Decompressing CSV..."
gunzip -c "$LOCAL_FILE" > "$TEMP_CSV"

echo "Extracting header..."
head -n 1 "$TEMP_CSV" > "$SMALL_CSV"

echo "Estimating number of rows for ~${TARGET_SIZE_MB}MB..."
# Get average line size from first 1000 rows (excluding header)
AVG_LINE_SIZE=$(tail -n +2 "$TEMP_CSV" | head -n 1000 | wc -c)
AVG_LINE_SIZE=$((AVG_LINE_SIZE / 1000))
# Calculate how many lines needed for ~5MB (5*1024*1024 bytes)
LINES_NEEDED=$(( (TARGET_SIZE_MB * 1024 * 1024) / AVG_LINE_SIZE ))

echo "Extracting $LINES_NEEDED rows..."
# Extract header + N rows
head -n 1 "$TEMP_CSV" > "$SMALL_CSV"
tail -n +2 "$TEMP_CSV" | head -n "$LINES_NEEDED" >> "$SMALL_CSV"

# Compress the smaller CSV
echo "Compressing reduced CSV..."
gzip -c "$SMALL_CSV" > "$SMALL_GZ"

# === UPLOAD TO S3 ===
echo "Uploading reduced dataset (~5MB) to S3 bucket: $BUCKET_NAME"
aws s3 cp "$SMALL_GZ" "s3://$BUCKET_NAME/"

echo "Clean up temporary files..."
rm -f "$TEMP_CSV" "$SMALL_CSV"

echo "Deployment and upload complete"



