#!/bin/bash

# Environment variables (use export or pass them when running the script)
STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME
APP_ID=$APP_ID
TENANT_ID=$TENANT_ID
CLIENT_SECRET=$CLIENT_SECRET

CONTAINER_NAME="dataprocessing"
MOUNT_POINT="/mnt/dataprocessing"

# Install dependencies if they are not installed
if ! command -v curl &> /dev/null; then
    echo "curl not found, installing..."
    sudo apt-get update
    sudo apt-get install -y curl
fi

if ! command -v jq &> /dev/null; then
    echo "jq not found, installing..."
    sudo apt-get install -y jq
fi

# Add the Microsoft repository and install blobfuse
if ! command -v blobfuse &> /dev/null; then
    echo "blobfuse not found, adding repository and installing..."
    
    # Add Microsoft repository and keys for blobfuse
    wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    
    # Install blobfuse
    sudo apt-get update
    sudo apt-get install -y blobfuse
fi

# Create a directory for the mount point if it doesn't exist
if [ ! -d "${MOUNT_POINT}" ]; then
    sudo mkdir -p "${MOUNT_POINT}"
fi

# Create a directory for blobfuse temporary cache if it doesn't exist
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
