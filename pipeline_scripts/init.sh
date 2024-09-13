#!/bin/bash


STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME
APP_ID=$APP_ID
TENANT_ID=$TENANT_ID
CLIENT_SECRET=$CLIENT_SECRET


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

# Authenticate using Azure Active Directory
echo "Fetching access token..."
RESPONSE=$(curl -s -X POST "https://login.microsoftonline.com/${TENANT_ID}/oauth2/token" \
  -d "grant_type=client_credentials" \
  -d "client_id=${APP_ID}" \
  -d "client_secret=${CLIENT_SECRET}" \
  -d "resource=https://storage.azure.com/")
ACCESS_TOKEN=$(echo $RESPONSE | jq -r .access_token)

if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" == "null" ]; then
  echo "Failed to fetch access token"
  echo "Response was: $RESPONSE"
  exit 1
fi

# Mount the Azure Blob Storage using Azure Active Directory and storage account name
echo "Mounting storage with Azure Active Directory authentication using blobfuse..."
sudo blobfuse ${MOUNT_POINT} \
    --tmp-path=/mnt/resource/blobfusetmp \
    --container-name=${CONTAINER_NAME} \
    --log-level=LOG_DEBUG \
    --file-cache-timeout-in-seconds=120 \
    --use-adls=true \
    --use-https=true \
    --auth-type=aad \
    --aad-client-id=${APP_ID} \
    --aad-tenant-id=${TENANT_ID} \
    --aad-client-secret=${CLIENT_SECRET} \
    --account-name=${STORAGE_ACCOUNT_NAME}

# Check if the mount command was successful
if [ $? -eq 0 ]; then
    echo "Container mounted successfully at ${MOUNT_POINT}!"
else
    echo "Failed to mount container."
fi