#!/bin/sh
set -e

# Debug (optional, remove later)
echo "S3_BUCKET=$S3_BUCKET"

# Force set storage config
ghost config storage.active ghost-storage-s3

ghost config storage.ghost-storage-s3.bucket "$S3_BUCKET"
ghost config storage.ghost-storage-s3.accessKeyId "$S3_ACCESS_KEY"
ghost config storage.ghost-storage-s3.secretAccessKey "$S3_SECRET_KEY"
ghost config storage.ghost-storage-s3.endpoint "$S3_ENDPOINT"
ghost config storage.ghost-storage-s3.forcePathStyle true

# Start Ghost
exec docker-entrypoint.sh node current/index.js
