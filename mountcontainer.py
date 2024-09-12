def mount_storage():
    # Fetch the secrets from the Databricks scope
    storage_account_name = dbutils.secrets.get(scope="azure-creds-scope", key="storage_account_name")
    app_id = dbutils.secrets.get(scope="azure-creds-scope", key="app-id")
    tenant_id = dbutils.secrets.get(scope="azure-creds-scope", key="tenant-id")
    client_secret = dbutils.secrets.get(scope="azure-creds-scope", key="client-secret")

    # Define the configuration for mounting
    configs = {
        "fs.azure.account.auth.type": "OAuth",
        "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
        "fs.azure.account.oauth2.client.id": app_id,
        "fs.azure.account.oauth2.client.secret": client_secret,
        "fs.azure.account.oauth2.client.endpoint": f"https://login.microsoftonline.com/{tenant_id}/oauth2/token"
    }

    # Check if the mount point already exists
    if not any(mount.mountPoint == '/mnt/dataprocessing' for mount in dbutils.fs.mounts()):
        dbutils.fs.mount(
            source=f"abfss://dataprocessing@{storage_account_name}.dfs.core.windows.net/",
            mount_point="/mnt/dataprocessing",
            extra_configs=configs
        )
        print("Container mounted successfully!")
    else:
        print("Already mounted!")

# Call the mount function
if __name__ == "__main__":
    mount_storage()