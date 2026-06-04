output "principal_id" {
  description = "Principal ID of the VM system-assigned managed identity."
  value       = azurerm_linux_virtual_machine.main.identity[0].principal_id
}

output "public_ip" {
  value = var.enable_public_ip ? azurerm_public_ip.main[0].ip_address : null
}

output "private_ip" {
  value = azurerm_network_interface.main.ip_configuration[0].private_ip_address
}
