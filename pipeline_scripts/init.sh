#!/bin/bash

# Pull workspace scope secrets
STORAGE_ACCOUNT_NAME={{secrets/azure-creds-scope/storage_account_name}}
APP_ID={{secrets/azure-creds-scope/app_id}}
TENANT_ID={{secrets/azure-creds-scope/tenant_id}}
CLIENT_SECRET={{secrets/azure-creds-scope/client-secret}}

CONTAINER_NAME="dataprocessing"
MOUNT_POINT="/mnt/dataprocessing"

# Install blobfuse if not already installed
if ! command -v blobfuse &> /dev/null; then
    echo "blobfuse not found, installing..."
    sudo apt-get update
    sudo apt-get install -y blobfuse
fi

# Create a directory for the mount point if it doesn't exist
if [ ! -d "${MOUNT_POINT}" ]; then
    sudo mkdir -p "${MOUNT_POINT}"
fi

# Create a directory for blobfuse temporary cache
if [ ! -d "/mnt/resource/blobfusetmp" ]; then
    sudo mkdir -p /mnt/resource/blobfusetmp
fi

# Authenticate using OAuth2
echo "Fetching OAuth2 token..."
ACCESS_TOKEN=$(curl -X POST "https://login.microsoftonline.com/${TENANT_ID}/oauth2/v2.0/token" \
  -d "grant_type=client_credentials" \
  -d "client_id=${APP_ID}" \
  -d "client_secret=${CLIENT_SECRET}" \
  -d "scope=https://storage.azure.com/.default" | jq -r .access_token)

if [ -z "$ACCESS_TOKEN" ]; then
  echo "Failed to fetch OAuth2 token"
  exit 1
fi

# Mount the Azure Blob Storage using OAuth2 and storage account name
echo "Mounting storage with OAuth2 authentication using blobfuse..."
sudo blobfuse ${MOUNT_POINT} \
    --tmp-path=/mnt/resource/blobfusetmp \
    --container-name=${CONTAINER_NAME} \
    --log-level=LOG_DEBUG \
    --file-cache-timeout-in-seconds=120 \
    --use-adls=true \
    --use-https=true \
    --auth-type=oauth \
    --token="${ACCESS_TOKEN}" \
    --account-name="${STORAGE_ACCOUNT_NAME}"

# Check if the mount command was successful
if [ $? -eq 0 ]; then
    echo "Container mounted successfully at ${MOUNT_POINT}!"
else
    echo "Failed to mount container."
fi