variable "project_id" {
  description = "The AKS project id"
  default     = "theia-cloud-terra"
}

variable "location" {
  description = "The zone of the created cluster"
  default     = "centralindia"
}

module "cluster" {
  source     = "../../modules/cluster_creation/aks/"
  project_id = var.project_id
  location   = var.location
}

variable "cert_manager_issuer_email" {
  description = "EMail address used to create certificates."
  default     = "mail.bot@act21.io"
}

variable "keycloak_admin_password" {
  description = "Keycloak Admin Password"
  sensitive   = true
  default     = "admin"
}

variable "postgres_postgres_password" {
  description = "Keycloak Postgres DB Postgres (Admin) Password"
  sensitive   = true
  default     = "admin"
}

variable "postgres_password" {
  description = "Keycloak Postgres DB Password"
  sensitive   = true
  default     = "admin"
}

variable "impaktApps_domain" {
  default = "sandbox.impaktapps.com"
}
resource "azurerm_public_ip" "host_ip" {
  depends_on          = [module.cluster]
  name                = "theia-cloud-nginx-ip"
  resource_group_name = module.cluster.cluster_resource_group_name
  location            = var.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

data "azurerm_kubernetes_cluster" "main" {
  depends_on          = [module.cluster]
  name                = "theiaCloudPool"
  resource_group_name = module.cluster.cluster_resource_group_name
}

provider "helm" {
  # kubernetes {
  #   config_path = "~/.kube/config"
  # }
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.main.kube_config.0.host
    username               = data.azurerm_kubernetes_cluster.main.kube_config.0.username
    password               = data.azurerm_kubernetes_cluster.main.kube_config.0.password
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
  }
}
provider "keycloak" {
  client_id = "admin-cli"
  # root_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
  tls_insecure_skip_verify = true
  username                 = "admin"
  password                 = var.keycloak_admin_password
  url                      = "https://${var.impaktApps_domain}/keycloak"
  initial_login            = false
}

module "helm" {
  source                      = "../../modules/helm"
  depends_on                  = [module.cluster]
  install_ingress_controller  = true
  cert_manager_issuer_email   = var.cert_manager_issuer_email
  cert_manager_cluster_issuer = "letsencrypt-prod"
  cert_manager_common_name    = var.impaktApps_domain
  hostname                    = var.impaktApps_domain
  keycloak_admin_password     = var.keycloak_admin_password
  postgresql_enabled          = true
  postgres_postgres_password  = var.postgres_postgres_password
  postgres_password           = var.postgres_password
  loadBalancerIP              = azurerm_public_ip.host_ip.ip_address
  resource_group_name         = module.cluster.cluster_resource_group_name
}



module "keycloak" {
  source = "../../modules/keycloak"

  depends_on = [module.helm]

  hostname                        = var.impaktApps_domain
  keycloak_test_user_foo_password = "foo"
  keycloak_test_user_bar_password = "bar"
}

