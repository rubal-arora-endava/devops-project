output "keyvault_id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.main.id
}

output "keyvault_uri" {
  description = "Vault URI used by applications and automation."
  value       = azurerm_key_vault.main.vault_uri
}
