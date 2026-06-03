output "public_ip" {
  value = var.enable_public_ip ? azurerm_public_ip.main[0].ip_address : null
}

output "private_ip" {
  value = azurerm_network_interface.main.ip_configuration[0].private_ip_address
}
