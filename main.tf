/**
 * # Cloud SQL PostgreSQL Module
 *
 * A reusable Terraform/OpenTofu module for deploying Google Cloud SQL PostgreSQL instances
 * with support for multiple databases and users with different permission levels.
 *
 * ## Features
 * - Multiple database support
 * - Configurable user roles (admin, read-write, read-only, custom)
 * - Preset configurations (budget, balanced, performance)
 * - Automatic password generation and Secret Manager integration
 * - PostgreSQL-specific performance tuning
 * - Read replica configuration
 * - Performance monitoring with pg_stat_statements
 */

# Generate a random suffix for unique naming
resource "random_id" "instance_suffix" {
  byte_length = var.random_suffix_length
}

locals {
  instance_name = var.use_random_suffix ? "${var.instance_name}-${random_id.instance_suffix.hex}" : var.instance_name

  # Determine actual configuration based on presets or custom values
  # When using presets, use preset values; when custom, use provided values (with fallback to balanced preset if null)
  final_machine_type = var.use_preset_config != "custom" ? var.config_presets[var.use_preset_config].machine_type : coalesce(var.machine_type, var.config_presets["balanced"].machine_type)
  final_disk_size    = var.use_preset_config != "custom" ? var.config_presets[var.use_preset_config].disk_size : coalesce(var.disk_size_gb, var.config_presets["balanced"].disk_size)
  final_edition      = var.use_preset_config != "custom" ? var.config_presets[var.use_preset_config].edition : coalesce(var.sql_edition, var.config_presets["balanced"].edition)

  # Extract memory size from machine type for calculations (in GB)
  memory_gb = tonumber(regex("\\d+", split("-", local.final_machine_type)[3])) / 1024
  vcpus     = tonumber(regex("\\d+", split("-", local.final_machine_type)[2]))
}

# ==========================================
# CLOUD SQL POSTGRESQL INSTANCE
# ==========================================

resource "google_sql_database_instance" "postgres" {
  name                = local.instance_name
  database_version    = var.postgres_version
  region              = var.region
  deletion_protection = var.deletion_protection
  project             = var.project_id

  settings {
    tier      = local.final_machine_type
    edition   = local.final_edition
    disk_type = var.disk_type
    disk_size = local.final_disk_size

    disk_autoresize       = var.disk_autoresize
    disk_autoresize_limit = var.disk_autoresize_limit_gb

    availability_type = var.availability_type

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      location                       = var.backup_location
      point_in_time_recovery_enabled = var.point_in_time_recovery
      transaction_log_retention_days = var.transaction_log_retention_days

      backup_retention_settings {
        retained_backups = var.backup_retention_days
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled    = var.ipv4_enabled
      private_network = var.private_network_id
      ssl_mode        = var.ssl_mode

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.cidr
        }
      }
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_window_update_track
    }

    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_string_length     = var.query_string_length
      record_application_tags = var.record_application_tags
      record_client_address   = var.record_client_address
      query_plans_per_minute  = var.query_plans_per_minute
    }

    # Data cache for Enterprise Plus
    dynamic "data_cache_config" {
      for_each = local.final_edition == "ENTERPRISE_PLUS" && var.data_cache_enabled ? [1] : []
      content {
        data_cache_enabled = true
      }
    }

    # PostgreSQL performance flags
    dynamic "database_flags" {
      for_each = merge(
        local.postgres_performance_flags,
        var.additional_database_flags
      )
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }

    user_labels = merge(
      var.labels,
      {
        managed_by  = "terraform"
        module      = "cloud-sql-postgres"
        environment = var.environment
      }
    )

    # Advanced configurations
    pricing_plan          = var.pricing_plan
    connector_enforcement = var.connector_enforcement

    dynamic "deny_maintenance_period" {
      for_each = var.deny_maintenance_periods
      content {
        start_date = deny_maintenance_period.value.start_date
        end_date   = deny_maintenance_period.value.end_date
        time       = deny_maintenance_period.value.time
      }
    }
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}

# ==========================================
# POSTGRESQL PERFORMANCE FLAGS
# ==========================================

locals {
  postgres_performance_flags = var.auto_generate_performance_flags ? {
    # Connection settings
    max_connections = var.max_connections

    # Memory settings (based on instance size)
    shared_buffers       = "${floor(local.memory_gb * 256)}MB" # ~25% of RAM
    effective_cache_size = "${floor(local.memory_gb * 768)}MB" # ~75% of RAM
    maintenance_work_mem = "${min(2048, floor(local.memory_gb * 64))}MB"
    work_mem             = "${max(4, floor(local.memory_gb * 4))}MB"

    # Checkpoint settings
    checkpoint_completion_target = "0.9"
    wal_buffers                  = "16MB"
    min_wal_size                 = "1GB"
    max_wal_size                 = "4GB"

    # Query optimization
    default_statistics_target = "100"
    random_page_cost          = var.disk_type == "PD_SSD" ? "1.1" : "4.0"
    effective_io_concurrency  = var.disk_type == "PD_SSD" ? "200" : "1"

    # Parallel query (for larger instances)
    max_parallel_workers_per_gather = local.vcpus >= 4 ? tostring(min(4, floor(local.vcpus / 2))) : "0"
    max_parallel_workers            = tostring(min(8, local.vcpus))
    max_worker_processes            = tostring(min(8, local.vcpus))

    # Logging
    log_statement               = var.log_all_statements ? "all" : "ddl"
    log_duration                = var.log_all_statements ? "on" : "off"
    log_min_duration_statement  = tostring(var.slow_query_threshold_ms)
    log_checkpoints             = "on"
    log_connections             = "on"
    log_disconnections          = "on"
    log_lock_waits              = "on"
    log_temp_files              = "0"
    log_autovacuum_min_duration = "0"

    # Extensions
    shared_preload_libraries = "pg_stat_statements"

    # Statement tracking
    "pg_stat_statements.track"         = "all"
    "pg_stat_statements.max"           = "10000"
    "pg_stat_statements.track_utility" = "off"

    # Autovacuum tuning
    autovacuum_max_workers          = tostring(min(4, max(2, floor(local.vcpus / 4))))
    autovacuum_vacuum_scale_factor  = "0.1"
    autovacuum_analyze_scale_factor = "0.05"
  } : {}
}

# ==========================================
# DATABASES
# ==========================================

resource "google_sql_database" "databases" {
  for_each = var.databases

  name      = each.key
  instance  = google_sql_database_instance.postgres.name
  charset   = try(each.value.charset, "UTF8")
  collation = try(each.value.collation, "en_US.UTF8")
  project   = var.project_id
}

# ==========================================
# USERS
# ==========================================

# Generate passwords for all users
resource "random_password" "user_passwords" {
  for_each = var.users

  length      = coalesce(each.value.password_length, var.default_password_length)
  special     = coalesce(each.value.password_special, true)
  min_upper   = coalesce(each.value.password_min_upper, 2)
  min_lower   = coalesce(each.value.password_min_lower, 2)
  min_numeric = coalesce(each.value.password_min_numeric, 2)
  min_special = coalesce(each.value.password_min_special, 2)
}

# Create users
resource "google_sql_user" "users" {
  for_each = var.users

  name     = each.key
  instance = google_sql_database_instance.postgres.name
  password = try(each.value.password, random_password.user_passwords[each.key].result)
  project  = var.project_id
}

# ==========================================
# PASSWORD STORAGE IN SECRET MANAGER
# ==========================================

resource "google_secret_manager_secret" "user_passwords" {
  for_each = var.store_passwords_in_secret_manager ? var.users : {}

  secret_id = "${local.instance_name}-${each.key}-password"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = merge(
    var.labels,
    {
      instance = local.instance_name
      user     = each.key
    }
  )
}

resource "google_secret_manager_secret_version" "user_passwords" {
  for_each = var.store_passwords_in_secret_manager ? var.users : {}

  secret      = google_secret_manager_secret.user_passwords[each.key].id
  secret_data = try(each.value.password, random_password.user_passwords[each.key].result)
}

# ==========================================
# POSTGRESQL PERMISSION SETUP SCRIPT
# ==========================================

locals {
  postgres_permissions = templatefile("${path.module}/templates/setup_permissions.sql.tpl", {
    databases = var.databases
    users     = var.users
  })
}

resource "local_file" "permission_script" {
  count = var.generate_permission_script ? 1 : 0

  filename = "${path.root}/setup_postgres_permissions.sql"
  content  = local.postgres_permissions

  file_permission = "0644"
}

# ==========================================
# POSTGRESQL EXTENSIONS SETUP SCRIPT
# ==========================================

locals {
  extensions_script = templatefile("${path.module}/templates/setup_extensions.sql.tpl", {
    databases  = var.databases
    extensions = var.postgresql_extensions
  })
}

resource "local_file" "extensions_script" {
  count = length(var.postgresql_extensions) > 0 ? 1 : 0

  filename = "${path.root}/setup_postgres_extensions.sql"
  content  = local.extensions_script

  file_permission = "0644"
}

# ==========================================
# READ REPLICAS
# ==========================================

resource "google_sql_database_instance" "read_replicas" {
  for_each = var.read_replicas

  name                 = "${local.instance_name}-${each.key}"
  database_version     = var.postgres_version
  region               = coalesce(each.value.region, var.region)
  master_instance_name = google_sql_database_instance.postgres.name
  project              = var.project_id

  replica_configuration {
    failover_target = coalesce(each.value.failover_target, false)
  }

  settings {
    tier              = coalesce(each.value.machine_type, local.final_machine_type)
    disk_type         = var.disk_type
    disk_size         = coalesce(each.value.disk_size, local.final_disk_size)
    disk_autoresize   = var.disk_autoresize
    availability_type = coalesce(each.value.availability_type, "ZONAL")

    ip_configuration {
      ipv4_enabled    = var.ipv4_enabled
      private_network = var.private_network_id
      ssl_mode        = var.ssl_mode

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.cidr
        }
      }
    }

    user_labels = merge(
      var.labels,
      {
        managed_by = "terraform"
        module     = "cloud-sql-postgres"
        type       = "read-replica"
        primary    = local.instance_name
      }
    )

    dynamic "database_flags" {
      for_each = merge(
        {
          # Read replica specific flags
          hot_standby_feedback        = "on"
          max_standby_streaming_delay = "30s"
        },
        try(each.value.database_flags, {})
      )
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}
