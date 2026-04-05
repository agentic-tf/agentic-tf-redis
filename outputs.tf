output "id" {
  description = "Resource ID of the Azure Cache for Redis instance."
  value       = azurerm_redis_cache.this.id
}

output "name" {
  description = "Name of the Azure Cache for Redis instance."
  value       = azurerm_redis_cache.this.name
}

output "hostname" {
  description = "Hostname of the Azure Cache for Redis instance."
  value       = azurerm_redis_cache.this.hostname
}

output "ssl_port" {
  description = "SSL port of the Azure Cache for Redis instance."
  value       = azurerm_redis_cache.this.ssl_port
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity."
  value       = azurerm_redis_cache.this.identity[0].principal_id
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint."
  value       = azurerm_private_endpoint.redis.id
}
