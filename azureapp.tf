data "azurerm_client_config" "current" {}

# Azure AD Application (App Registration)
resource "azuread_application" "etl_app" {
  display_name = "etl-app"
}

# Azure AD Service Principal
resource "azuread_service_principal" "etl_sp" {
  client_id = azuread_application.etl_app.client_id
}

# Create a client secret for the Service Principal
resource "azuread_service_principal_password" "etl_sp_password" {
  service_principal_id = azuread_service_principal.etl_sp.object_id
}

# Assign the "Storage Blob Data Contributor" role to the Service Principal
resource "azurerm_role_assignment" "etl_blob_contributor" {
  scope                = azurerm_storage_account.etlstorage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.etl_sp.object_id
}

# Output the App Registration (Service Principal) details
output "app_id" {
  value = azuread_application.etl_app.client_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "client_secret" {
  value     = azuread_service_principal_password.etl_sp_password.value
  sensitive = true
}

