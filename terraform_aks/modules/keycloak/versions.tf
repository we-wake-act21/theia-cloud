terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.2.0"
    }
  }

  required_version = ">= 1.4.0"
}

# provider "keycloak" {
#   client_id     = "admin-cli"
#   username      = "admin"
#   password      = var.keycloak_admin_password
#   url           = "https://${var.hostname}.sslip.io/keycloak"
#   initial_login = false
# }
