variable "project_id" {
  description = "The AKS project id"
}
variable "location" {
  description = "The zone of the created cluster"
}
variable "cluster_name" {
  default     = "aks-theia-cloud2"
  description = "The name of the created cluster"
}

variable "primary_node_pool_name" {
  default     = "theiaCloudPool"
  description = "The name of the primary node pool"
}

variable "primary_node_pool_machine" {
  default     = "Standard_DS2_v2"
  description = "Machine Type of the primary node pool"
}

variable "primary_node_pool_initial_nodes" {
  default     = 1
  description = "Initial number of nodes for the primary node pool"
}

variable "primary_node_pool_max_nodes" {
  default     = 2
  description = "Maximum number of nodes for the primary node pool"
}

# creating a new resource group
resource "azurerm_resource_group" "primary" {
  name     = var.cluster_name
  location = var.location
}





# creating kubernetes cluster
resource "azurerm_kubernetes_cluster" "primary_cluster" {
  name                = var.primary_node_pool_name
  location            = var.location
  resource_group_name = azurerm_resource_group.primary.name
  dns_prefix          = "sandbox"
  depends_on          = [azurerm_resource_group.primary]




  default_node_pool {
    name                = "primarypool"
    node_count          = var.primary_node_pool_initial_nodes
    vm_size             = "Standard_D2_v2"
    max_count           = var.primary_node_pool_max_nodes
    enable_auto_scaling = true
    min_count           = var.primary_node_pool_initial_nodes
  }

  network_profile {
    load_balancer_sku = "basic"
    network_plugin    = "kubenet"
  }

  identity {
    type = "SystemAssigned"
  }

  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${var.cluster_name} --name ${var.primary_node_pool_name} --overwrite-existing"
  }

}


# data "azurerm_client_config" "current" {
#   depends_on = [azurerm_resource_group.primary]
# }

resource "azurerm_role_assignment" "ingress-user" {
  depends_on           = [azurerm_kubernetes_cluster.primary_cluster]
  scope                = "/subscriptions/a1e39925-4947-4373-9be8-8b0a25171dd7"
  role_definition_name = "ingress-nginx-ip-reader"
  principal_id         = azurerm_kubernetes_cluster.primary_cluster.identity[0].principal_id
}


# exporting the created cluster data
data "azurerm_kubernetes_cluster" "primary_cluster" {
  name                = azurerm_kubernetes_cluster.primary_cluster.name
  resource_group_name = azurerm_kubernetes_cluster.primary_cluster.resource_group_name
}


