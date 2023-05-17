# terraform {
#   required_providers {
#     helm = {
#       source  = "hashicorp/helm"
#       version = ">= 2.9.0"
#     }
#     azapi = {
#       source  = "azure/azapi"
#       version = "=0.1.0"
#     }
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "=3.0.2"
#     }
#   }

#   required_version = ">= 1.4.0"
# }

# provider "azapi" {
#   default_location = "centralindia"
#   default_tags = {
#     team = "Azure deployments"
#   }
# }

# provider "azurerm" {
#   features {}
# }
