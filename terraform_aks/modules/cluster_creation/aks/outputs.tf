output "cluster_resource_group_name" {
  value = data.azurerm_kubernetes_cluster.primary_cluster.resource_group_name
}

output "cluster_resource" {
  value = data.azurerm_kubernetes_cluster.primary_cluster
}

