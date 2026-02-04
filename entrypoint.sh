#!/bin/sh
set -e

echo "Starting Ghost with R2 (S3 Adapter)..."

# Validate
if [ -z "$R2_BUCKET" ]; then
  echo "ERROR: R2_BUCKET is not set"
  exit 1
fi

# Configure storage
ghost config storage.active ghost-storage-adapter-s3

ghost config storage.ghost-storage-adapter-s3.accessKeyId "$R2_ACCESS_KEY"
ghost config storage.ghost-storage-adapter-s3.secretAccessKey "$R2_SECRET"
ghost config storage.ghost-storage-adapter-s3.bucket "$R2_BUCKET"
ghost config storage.ghost-storage-adapter-s3.endpoint "$R2_ENDPOINT"
ghost config storage.ghost-storage-adapter-s3.region "auto"
ghost config storage.ghost-storage-adapter-s3.pathStyle true

# Optional CDN
if [ -n "$R2_ASSET_HOST" ]; then
  ghost config storage.ghost-storage-adapter-s3.assetHost "$R2_ASSET_HOST"
fi

echo "Storage configured. Starting Ghost..."

exec docker-entrypoint.sh node current/index.js
