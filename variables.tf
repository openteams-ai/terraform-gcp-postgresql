# ==========================================
# REQUIRED VARIABLES
# ==========================================

variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
}

variable "instance_name" {
  description = "Base name for the Cloud SQL PostgreSQL instance"
  type        = string
}

variable "region" {
  description = "The GCP region for the Cloud SQL instance"
  type        = string
}

# ==========================================
# POSTGRESQL CONFIGURATION
# ==========================================

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "POSTGRES_15"

  validation {
    condition = contains([
      "POSTGRES_12",
      "POSTGRES_13",
      "POSTGRES_14",
      "POSTGRES_15",
      "POSTGRES_16",
      "POSTGRES_17",
      "POSTGRES_18"
    ], var.postgres_version)
    error_message = "Invalid PostgreSQL version. Must be POSTGRES_12, 13, 14, 15, 16, 17, or 18."
  }
}

variable "postgresql_extensions" {
  description = "List of PostgreSQL extensions to enable"
  type        = list(string)
  default = [
    "pg_stat_statements",
    "pgcrypto",
    "uuid-ossp"
  ]
}

# ==========================================
# INSTANCE SIZING
# ==========================================

variable "use_preset_config" {
  description = "Use preset configuration (budget, balanced, performance, or custom)"
  type        = string
  default     = "balanced"

  validation {
    condition     = contains(["budget", "balanced", "performance", "custom"], var.use_preset_config)
    error_message = "Preset must be budget, balanced, performance, or custom."
  }
}

variable "config_presets" {
  description = "Preset configurations for different use cases"
  type = map(object({
    machine_type = string
    disk_size    = number
    edition      = string
  }))
  default = {
    budget = {
      machine_type = "db-custom-2-7680" # 2 vCPUs, 7.5GB RAM
      disk_size    = 100
      edition      = "ENTERPRISE"
    }
    balanced = {
      machine_type = "db-custom-4-16384" # 4 vCPUs, 16GB RAM
      disk_size    = 500
      edition      = "ENTERPRISE"
    }
    performance = {
      machine_type = "db-custom-8-32768" # 8 vCPUs, 32GB RAM
      disk_size    = 1000
      edition      = "ENTERPRISE_PLUS"
    }
  }
}

variable "machine_type" {
  description = "Machine type for the instance (used when use_preset_config is 'custom')"
  type        = string
  default     = null
}

variable "sql_edition" {
  description = "Cloud SQL edition: ENTERPRISE or ENTERPRISE_PLUS"
  type        = string
  default     = null

  validation {
    condition     = var.sql_edition == null || contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.sql_edition)
    error_message = "SQL edition must be either ENTERPRISE or ENTERPRISE_PLUS."
  }
}

variable "disk_type" {
  description = "Type of disk: PD_SSD or PD_HDD"
  type        = string
  default     = "PD_SSD"
}

variable "disk_size_gb" {
  description = "Initial disk size in GB"
  type        = number
  default     = null

  validation {
    condition     = var.disk_size_gb == null || (var.disk_size_gb >= 10 && var.disk_size_gb <= 65536)
    error_message = "Disk size must be between 10 and 65536 GB."
  }
}

variable "disk_autoresize" {
  description = "Enable automatic storage increase"
  type        = bool
  default     = true
}

variable "disk_autoresize_limit_gb" {
  description = "Maximum disk size when autoresize is enabled (0 = unlimited)"
  type        = number
  default     = 0
}

# ==========================================
# DATABASES AND USERS
# ==========================================

variable "databases" {
  description = "Map of databases to create with optional charset and collation"
  type = map(object({
    charset   = optional(string)
    collation = optional(string)
  }))
  default = {
    main = {}
  }
}

variable "users" {
  description = "Map of users to create with their configuration"
  type = map(object({
    role                 = optional(string, "readonly") # admin, readwrite, readonly, custom
    password             = optional(string)             # If not provided, will be generated
    password_length      = optional(number)
    password_special     = optional(bool)
    password_min_upper   = optional(number)
    password_min_lower   = optional(number)
    password_min_numeric = optional(number)
    password_min_special = optional(number)
    custom_grants        = optional(map(list(string))) # For custom role: map of database to list of grants
  }))
  default = {
    app_user = {
      role = "readwrite"
    }
  }
}

variable "default_password_length" {
  description = "Default length for generated passwords"
  type        = number
  default     = 16
}

variable "store_passwords_in_secret_manager" {
  description = "Store generated passwords in Google Secret Manager"
  type        = bool
  default     = true
}

variable "generate_permission_script" {
  description = "Generate SQL script for setting up user permissions"
  type        = bool
  default     = true
}

# ==========================================
# POSTGRESQL PERFORMANCE TUNING
# ==========================================

variable "auto_generate_performance_flags" {
  description = "Automatically generate PostgreSQL performance tuning flags based on instance size"
  type        = bool
  default     = true
}

variable "max_connections" {
  description = "Maximum number of connections"
  type        = string
  default     = "200"
}

variable "slow_query_threshold_ms" {
  description = "Log queries slower than this threshold (milliseconds)"
  type        = number
  default     = 1000
}

variable "log_all_statements" {
  description = "Log all SQL statements (use with caution in production)"
  type        = bool
  default     = false
}

variable "additional_database_flags" {
  description = "Additional PostgreSQL configuration flags"
  type        = map(string)
  default     = {}
}

# ==========================================
# AVAILABILITY AND BACKUP
# ==========================================

variable "availability_type" {
  description = "Availability type: ZONAL or REGIONAL"
  type        = string
  default     = "ZONAL"

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "Availability type must be either ZONAL or REGIONAL."
  }
}

variable "backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "HH:MM format time for backup window"
  type        = string
  default     = "02:00"
}

variable "backup_location" {
  description = "Location for backups"
  type        = string
  default     = null
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "transaction_log_retention_days" {
  description = "Number of days to retain transaction logs"
  type        = number
  default     = 7
}

variable "backup_retention_days" {
  description = "Number of backup retention days"
  type        = number
  default     = 30
}

# ==========================================
# NETWORK CONFIGURATION
# ==========================================

variable "ipv4_enabled" {
  description = "Enable IPv4 connectivity"
  type        = bool
  default     = true
}

variable "authorized_networks" {
  description = "List of authorized networks for IP whitelisting"
  type = list(object({
    name = string
    cidr = string
  }))
  default = []
}

variable "private_network_id" {
  description = "VPC network ID for private IP connectivity"
  type        = string
  default     = null
}

variable "ssl_mode" {
  description = "SSL mode: ALLOW_UNENCRYPTED_AND_ENCRYPTED, ENCRYPTED_ONLY, or TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
  type        = string
  default     = "ENCRYPTED_ONLY"
}

# ==========================================
# MONITORING
# ==========================================

variable "query_insights_enabled" {
  description = "Enable Query Insights for performance monitoring"
  type        = bool
  default     = true
}

variable "query_string_length" {
  description = "Maximum query string length to log"
  type        = number
  default     = 1024
}

variable "record_application_tags" {
  description = "Record application tags in Query Insights"
  type        = bool
  default     = true
}

variable "record_client_address" {
  description = "Record client address in Query Insights"
  type        = bool
  default     = true
}

variable "query_plans_per_minute" {
  description = "Number of query plans to sample per minute"
  type        = number
  default     = 5
}

variable "data_cache_enabled" {
  description = "Enable data cache (Enterprise Plus only)"
  type        = bool
  default     = true
}

# ==========================================
# MAINTENANCE
# ==========================================

variable "maintenance_window_day" {
  description = "Day of week for maintenance window (1-7, 1 = Monday)"
  type        = number
  default     = 7
}

variable "maintenance_window_hour" {
  description = "Hour of day for maintenance window (0-23)"
  type        = number
  default     = 3
}

variable "maintenance_window_update_track" {
  description = "Update track: stable or canary"
  type        = string
  default     = "stable"
}

variable "deny_maintenance_periods" {
  description = "List of deny maintenance periods"
  type = list(object({
    start_date = string
    end_date   = string
    time       = string
  }))
  default = []
}

# ==========================================
# READ REPLICAS
# ==========================================

variable "read_replicas" {
  description = "Map of read replicas to create"
  type = map(object({
    region            = optional(string)
    machine_type      = optional(string)
    disk_size         = optional(number)
    availability_type = optional(string)
    failover_target   = optional(bool)
    database_flags    = optional(map(string))
  }))
  default = {}
}

# ==========================================
# ADVANCED CONFIGURATION
# ==========================================

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "use_random_suffix" {
  description = "Add random suffix to instance name for uniqueness"
  type        = bool
  default     = true
}

variable "random_suffix_length" {
  description = "Length of random suffix in bytes"
  type        = number
  default     = 4
}

variable "pricing_plan" {
  description = "Pricing plan: PER_USE or PACKAGE"
  type        = string
  default     = "PER_USE"
}

variable "connector_enforcement" {
  description = "Enforce use of Cloud SQL connector"
  type        = string
  default     = "NOT_REQUIRED"
}

variable "timeouts" {
  description = "Timeout configurations for resource operations"
  type = object({
    create = optional(string, "30m")
    update = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default = {}
}
