variable "project_id" {
  description = "The AKS project id"
}
variable "location" {
  description = "The zone of the created cluster"
}

variable "cluster_name" {
  default     = "impaktapps-cloud-cluster"
  description = "The name of the created cluster"
}

variable "primary_node_pool_name" {
  default     = "impaktCloudPool"
  description = "The name of the primary node pool"
}

variable "primary_node_pool_machine" {
  default     = "Standard_D4s_v3"
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

variable "subscription" {
  default = "/subscriptions/a1e39925-4947-4373-9be8-8b0a25171dd7"
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
    vm_size             = var.primary_node_pool_machine
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


resource "azurerm_role_definition" "ingress-user" {
  name  = "ingress-nginx-reader"
  scope = var.subscription

  permissions {
    actions = [
      "*/read",
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/publicIPAddresses/write",
      "Microsoft.Network/publicIPAddresses/join/action"
    ]
    not_actions = []
  }

  assignable_scopes = [
    var.subscription
  ]
}

resource "azurerm_role_assignment" "ingress-user" {
  depends_on           = [azurerm_kubernetes_cluster.primary_cluster]
  scope                = var.subscription
  role_definition_name = azurerm_role_definition.ingress-user.name
  principal_id         = azurerm_kubernetes_cluster.primary_cluster.identity[0].principal_id
}


# exporting the created cluster data
data "azurerm_kubernetes_cluster" "primary_cluster" {
  name                = azurerm_kubernetes_cluster.primary_cluster.name
  resource_group_name = azurerm_kubernetes_cluster.primary_cluster.resource_group_name
}


