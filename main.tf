locals {
  private_dns_zone_ids = var.create_private_dns_zones ? {
    redisCache = azurerm_private_dns_zone.redis[0].id
  } : var.private_dns_zone_ids
}

resource "azurerm_redis_cache" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku_name

  # ── Security hardening ────────────────────────────────────────────────
  # I.AZR.0076 — no public access; traffic via private endpoint only
  public_network_access_enabled = false

  # I.AZR.0077 / I.AZR.0223 — SSL only; disable non-TLS port 6379
  non_ssl_port_enabled = false

  # I.AZR.0063 — minimum TLS 1.2
  minimum_tls_version = var.minimum_tls_version

  # I.AZR.0290 — Entra ID authentication
  redis_configuration {
    active_directory_authentication_enabled = true
  }

  # I.AZR.0019 — Managed Identity
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ── Private Endpoint ──────────────────────────────────────────────────
# I.AZR.0224 — connectivity via private endpoint
resource "azurerm_private_endpoint" "redis" {
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = contains(keys(local.private_dns_zone_ids), "redisCache") ? [1] : []
    content {
      name                 = "redis-dns-group"
      private_dns_zone_ids = [local.private_dns_zone_ids["redisCache"]]
    }
  }

  tags = var.tags
}

# ── Private DNS Zone ──────────────────────────────────────────────────
resource "azurerm_private_dns_zone" "redis" {
  count               = var.create_private_dns_zones ? 1 : 0
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  count                 = var.create_private_dns_zones ? 1 : 0
  name                  = "${var.name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.redis[0].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
  tags                  = var.tags
}

# ── Diagnostic Settings (I.AZR.0013) ─────────────────────────────────
resource "azurerm_monitor_diagnostic_setting" "redis" {
  count = var.log_analytics_workspace_id != "" ? 1 : 0

  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_redis_cache.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ConnectedClientList"
  }

  metric {
    category = "AllMetrics"
  }
}
