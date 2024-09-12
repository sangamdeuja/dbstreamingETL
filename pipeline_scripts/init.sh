#!/bin/bash

# Pull workspace scope secrets
STORAGE_ACCOUNT_NAME={{secrets/azure-creds-scope/storage_account_name}}
APP_ID={{secrets/azure-creds-scope/app_id}}
TENANT_ID={{secrets/azure-creds-scope/tenant_id}}
CLIENT_SECRET={{secrets/azure-creds-scope/client-secret}}



# Configuration parameters for mounting the Azure Data Lake Storage
CONFIGS=(
  "fs.azure.account.auth.type=OAuth"
  "fs.azure.account.oauth.provider.type=org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider"
  "fs.azure.account.oauth2.client.id=${APP_ID}"
  "fs.azure.account.oauth2.client.secret=${CLIENT_SECRET}"
  "fs.azure.account.oauth2.client.endpoint=https://login.microsoftonline.com/${TENANT_ID}/oauth2/token"
)

MOUNT_POINT="/mnt/dataprocessing"
# SOURCE_URI="abfss://dataprocessing@${STORAGE_ACCOUNT_NAME}.dfs.core.windows.net/"

# Function to check if the mount already exists
mount_exists() {
  databricks fs mounts | grep -q "${MOUNT_POINT}"
}

# Mount the Azure Data Lake if not already mounted
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

# Create a directory for blobfuse configuration
if [ ! -d "/mnt/resource/blobfusetmp" ]; then
    sudo mkdir -p /mnt/resource/blobfusetmp
fi

# Create a fuse connection using blobfuse
echo "Mounting storage with blobfuse..."
sudo blobfuse ${MOUNT_POINT} --container-name=${CONTAINER_NAME} \
    --tmp-path=/mnt/resource/blobfusetmp \
    --account-name=${STORAGE_ACCOUNT_NAME} \
    --account-key=${AZURE_STORAGE_KEY} \
    -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 \
    --log-level=LOG_DEBUG

if [ $? -eq 0 ]; then
    echo "Container mounted successfully at ${MOUNT_POINT}!"
else
    echo "Failed to mount container."
fi
