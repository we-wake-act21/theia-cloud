variable "project_id" {
  description = "The AKS project id"
  default     = "impaktapps-cloud"
}

variable "location" {
  description = "The zone of the created cluster"
  default     = "centralindia"
}

variable "poolName" {
  default = "impaktCloudPool"
}

module "cluster" {
  source                 = "../../modules/cluster_creation/aks/"
  project_id             = var.project_id
  location               = var.location
  subscription           = "/subscriptions/a1e39925-4947-4373-9be8-8b0a25171dd7"
  primary_node_pool_name = var.poolName
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

# variable "impaktApps_domain" {
#   default = "sandbox.impaktapps.com"
# }
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
  name                = var.poolName
  resource_group_name = module.cluster.cluster_resource_group_name
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
  # kubernetes {
  #   host                   = data.azurerm_kubernetes_cluster.main.kube_config.0.host
  #   username               = data.azurerm_kubernetes_cluster.main.kube_config.0.username
  #   password               = data.azurerm_kubernetes_cluster.main.kube_config.0.password
  #   client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  #   client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  #   cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
  # }
}
provider "keycloak" {
  client_id                = "admin-cli"
  tls_insecure_skip_verify = true
  username                 = "admin"
  password                 = var.keycloak_admin_password
  url                      = "https://${azurerm_public_ip.host_ip.ip_address}.sslip.io/keycloak"
  initial_login            = false
}

module "helm" {
  source                      = "../../modules/helm"
  depends_on                  = [module.cluster]
  install_ingress_controller  = true
  cert_manager_issuer_email   = var.cert_manager_issuer_email
  cert_manager_cluster_issuer = "letsencrypt-prod"
  cert_manager_common_name    = "${azurerm_public_ip.host_ip.ip_address}.sslip.io"
  hostname                    = "${azurerm_public_ip.host_ip.ip_address}.sslip.io"
  keycloak_admin_password     = var.keycloak_admin_password
  postgresql_enabled          = true
  postgres_postgres_password  = var.postgres_postgres_password
  postgres_password           = var.postgres_password
  loadBalancerIP              = azurerm_public_ip.host_ip.ip_address
  resource_group_name         = module.cluster.cluster_resource_group_name
  service_hostname            = "service.${azurerm_public_ip.host_ip.ip_address}.sslip.io"
  landing_hostname            = "${azurerm_public_ip.host_ip.ip_address}.sslip.io"
  instance_hostname           = "instance.${azurerm_public_ip.host_ip.ip_address}.sslip.io"
}

module "keycloak" {
  source                          = "../../modules/keycloak"
  depends_on                      = [module.helm]
  hostname                        = "${azurerm_public_ip.host_ip.ip_address}.sslip.io"
  keycloak_test_user_foo_password = "foo"
  keycloak_test_user_bar_password = "bar"
}

resource "null_resource" "keycloak-permission" {
  depends_on = [module.keycloak]
  provisioner "local-exec" {
    command     = "kubectl create clusterrolebinding operator-api-access --clusterrole=cluster-admin --serviceaccount=theiacloud:operator-api-service-account -n theiacloud"
    interpreter = ["PowerShell", "-Command"]
  }

  provisioner "local-exec" {
    command     = "kubectl create clusterrolebinding service-api-access --clusterrole=cluster-admin --serviceaccount=theiacloud:service-api-service-account -n theiacloud"
    interpreter = ["PowerShell", "-Command"]
  }
}

