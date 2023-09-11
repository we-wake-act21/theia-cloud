output "try_now" {
  description = "Try Now URL."
  value       = "https://${azurerm_public_ip.host_ip.ip_address}.sslip.io/"
}

