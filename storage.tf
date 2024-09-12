# Create a storage account
resource "azurerm_storage_account" "etlstorage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # LRS (Locally Redundant Storage)
  is_hns_enabled           = true
}

resource "azurerm_storage_data_lake_gen2_filesystem" "dataprocessing" {
  name               = "dataprocessing"
  storage_account_id = azurerm_storage_account.etlstorage.id
}
resource "azurerm_storage_data_lake_gen2_path" "raw_data" {
  path               = "raw_data"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.dataprocessing.name
  storage_account_id = azurerm_storage_account.etlstorage.id
  resource           = "directory"
}
resource "azurerm_storage_data_lake_gen2_path" "bronze" {
  path               = "bronze_layer"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.dataprocessing.name
  storage_account_id = azurerm_storage_account.etlstorage.id
  resource           = "directory"
}

resource "azurerm_storage_data_lake_gen2_path" "silver" {
  path               = "silver_layer"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.dataprocessing.name
  storage_account_id = azurerm_storage_account.etlstorage.id
  resource           = "directory"
}

resource "azurerm_storage_data_lake_gen2_path" "gold" {
  path               = "gold_layer"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.dataprocessing.name
  storage_account_id = azurerm_storage_account.etlstorage.id
  resource           = "directory"
}


