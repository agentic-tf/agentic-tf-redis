# ── Identity ──────────────────────────────────────────────────────────
variable "name" {
  type        = string
  description = "Name of the Azure Cache for Redis instance."
}

variable "location" {
  type        = string
  description = "Azure region for the Redis cache."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into."
}

# ── Networking ────────────────────────────────────────────────────────
variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint. Required for private connectivity."

  validation {
    condition     = length(var.private_endpoint_subnet_id) > 0
    error_message = "private_endpoint_subnet_id must not be empty."
  }
}

variable "virtual_network_id" {
  type        = string
  description = "Virtual network ID for the private DNS zone link."

  validation {
    condition     = length(var.virtual_network_id) > 0
    error_message = "virtual_network_id must not be empty."
  }
}

variable "create_private_dns_zones" {
  type        = bool
  description = "Create private DNS zones for the Redis private endpoint. Set false if centrally managed."
  default     = true
}

variable "private_dns_zone_ids" {
  type        = map(string)
  description = "Existing private DNS zone IDs keyed by subresource name when create_private_dns_zones = false."
  default     = {}
}

# ── Service-specific ─────────────────────────────────────────────────
variable "sku_name" {
  type        = string
  description = "Redis cache SKU: Basic, Standard, or Premium."
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "sku_name must be one of: Basic, Standard, Premium."
  }
}

variable "family" {
  type        = string
  description = "Redis cache family: C (Basic/Standard) or P (Premium)."
  default     = "C"

  validation {
    condition     = contains(["C", "P"], var.family)
    error_message = "family must be C or P."
  }
}

variable "capacity" {
  type        = number
  description = "Redis cache capacity (0-6 for C family, 1-5 for P family)."
  default     = 1

  validation {
    condition     = var.capacity >= 0 && var.capacity <= 6
    error_message = "capacity must be between 0 and 6."
  }
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for Redis cache connections."
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.0, 1.1, or 1.2."
  }
}

# ── Operational ──────────────────────────────────────────────────────
variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for diagnostic logs. Empty string to skip."
  default     = ""
}

# ── Tags ─────────────────────────────────────────────────────────────
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}
