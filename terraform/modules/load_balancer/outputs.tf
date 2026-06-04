output "id" {
  description = "Resource ID of the load balancer."
  value       = azurerm_lb.main.id
}

output "lb_public_ip" {
  value = azurerm_public_ip.lb.ip_address
}

output "lb_backend_address_pool_id" {
  value = azurerm_lb_backend_address_pool.pool.id
}
