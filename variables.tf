variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "databricksRG"
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Name of the Storage Account"
  type        = string
  default     = "sangametlstorage"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}


