#!/bin/sh
set -e

echo "Starting Ghost with R2/S3 storage..."

# Validate env vars
if [ -z "$S3_BUCKET" ]; then
  echo "ERROR: S3_BUCKET is not set"
  exit 1
fi

# Configure storage at runtime
ghost config storage.active ghost-storage-s3

ghost config storage.ghost-storage-s3.bucket "$S3_BUCKET"
ghost config storage.ghost-storage-s3.accessKeyId "$S3_ACCESS_KEY"
ghost config storage.ghost-storage-s3.secretAccessKey "$S3_SECRET_KEY"
ghost config storage.ghost-storage-s3.endpoint "$S3_ENDPOINT"
ghost config storage.ghost-storage-s3.forcePathStyle true

# Optional CDN domain
if [ -n "$S3_ASSET_HOST" ]; then
  ghost config storage.ghost-storage-s3.assetHost "$S3_ASSET_HOST"
fi

echo "Storage configured. Starting Ghost..."

# Start Ghost
exec docker-entrypoint.sh node current/index.js
