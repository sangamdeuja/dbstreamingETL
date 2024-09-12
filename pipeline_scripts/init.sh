#!/bin/bash


# Define the Azure AD credentials and storage account information using Databricks secrets
STORAGE_ACCOUNT_NAME=$(databricks secrets get --scope azure-creds-scope --key storage_account_name)
APP_ID=$(databricks secrets get --scope azure-creds-scope --key app-id)
TENANT_ID=$(databricks secrets get --scope azure-creds-scope --key tenant-id)
CLIENT_SECRET=$(databricks secrets get --scope azure-creds-scope --key client-secret)

# Configuration parameters for mounting the Azure Data Lake Storage
CONFIGS=(
  "fs.azure.account.auth.type=OAuth"
  "fs.azure.account.oauth.provider.type=org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider"
  "fs.azure.account.oauth2.client.id=${APP_ID}"
  "fs.azure.account.oauth2.client.secret=${CLIENT_SECRET}"
  "fs.azure.account.oauth2.client.endpoint=https://login.microsoftonline.com/${TENANT_ID}/oauth2/token"
)

MOUNT_POINT="/mnt/dataprocessing"
SOURCE_URI="abfss://dataprocessing@${STORAGE_ACCOUNT_NAME}.dfs.core.windows.net/"

# Function to check if the mount already exists
mount_exists() {
  databricks fs mounts | grep -q "${MOUNT_POINT}"
}

# Mount the Azure Data Lake if not already mounted
if mount_exists; then
  echo "Already mounted!"
else
  echo "Mounting storage..."
  databricks fs mount \
    --source "${SOURCE_URI}" \
    --mount-point "${MOUNT_POINT}" \
    --extra-configs "${CONFIGS[@]}"
  
  if [ $? -eq 0 ]; then
    echo "Container mounted successfully!"
  else
    echo "Failed to mount container."
  fi
fi
