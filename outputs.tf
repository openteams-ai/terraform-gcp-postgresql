# ==========================================
# INSTANCE OUTPUTS
# ==========================================

output "instance_name" {
  description = "The name of the Cloud SQL PostgreSQL instance"
  value       = google_sql_database_instance.postgres.name
}

output "instance_connection_name" {
  description = "The connection name for the Cloud SQL instance (project:region:instance)"
  value       = google_sql_database_instance.postgres.connection_name
}

output "instance_self_link" {
  description = "The self link of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.self_link
}

output "instance_service_account_email" {
  description = "The service account email associated with the instance"
  value       = google_sql_database_instance.postgres.service_account_email_address
}

# ==========================================
# IP ADDRESSES
# ==========================================

output "public_ip_address" {
  description = "The public IPv4 address assigned to the instance"
  value       = try(google_sql_database_instance.postgres.public_ip_address, null)
}

output "private_ip_address" {
  description = "The private IP address assigned to the instance"
  value       = try(google_sql_database_instance.postgres.private_ip_address, null)
}

# ==========================================
# DATABASE OUTPUTS
# ==========================================

output "databases" {
  description = "Map of created databases"
  value = {
    for k, v in google_sql_database.databases :
    k => {
      name      = v.name
      charset   = v.charset
      collation = v.collation
    }
  }
}

output "database_names" {
  description = "List of database names"
  value       = [for db in google_sql_database.databases : db.name]
}

# ==========================================
# USER OUTPUTS
# ==========================================

output "users" {
  description = "Map of created users with their details"
  value = {
    for k, v in google_sql_user.users :
    k => {
      name = v.name
      role = try(var.users[k].role, "custom")
    }
  }
}

output "user_passwords" {
  description = "Map of user passwords (sensitive)"
  value = {
    for k, v in var.users :
    k => try(v.password, random_password.user_passwords[k].result)
  }
  sensitive = true
}

output "user_secret_ids" {
  description = "Map of Secret Manager secret IDs for user passwords"
  value = {
    for k, v in google_secret_manager_secret.user_passwords :
    k => v.secret_id
  }
}

# ==========================================
# CONNECTION INFORMATION
# ==========================================

output "connection_strings" {
  description = "PostgreSQL connection strings for different scenarios"
  value = {
    public_ip = var.ipv4_enabled ? {
      for user_name in keys(var.users) :
      user_name => "postgresql://${user_name}:<PASSWORD>@${google_sql_database_instance.postgres.public_ip_address}:5432/<DATABASE>?sslmode=require"
    } : {}

    cloud_sql_proxy = {
      for user_name in keys(var.users) :
      user_name => "postgresql://${user_name}:<PASSWORD>@127.0.0.1:5432/<DATABASE>"
    }

    psql_commands = {
      for user_name in keys(var.users) :
      user_name => "PGPASSWORD=<PASSWORD> psql -h ${google_sql_database_instance.postgres.public_ip_address} -U ${user_name} -d <DATABASE>"
    }
  }
}

output "cloud_sql_proxy_command" {
  description = "Command to start Cloud SQL proxy for PostgreSQL"
  value       = "cloud-sql-proxy --port=5432 ${google_sql_database_instance.postgres.connection_name}"
}

# ==========================================
# READ REPLICA OUTPUTS
# ==========================================

output "read_replicas" {
  description = "Map of read replica information"
  value = {
    for k, v in google_sql_database_instance.read_replicas :
    k => {
      name               = v.name
      connection_name    = v.connection_name
      public_ip_address  = try(v.public_ip_address, null)
      private_ip_address = try(v.private_ip_address, null)
      region             = v.region
    }
  }
}

# ==========================================
# CONFIGURATION OUTPUTS
# ==========================================

output "configuration" {
  description = "Current configuration of the PostgreSQL instance"
  value = {
    postgres_version  = var.postgres_version
    machine_type      = local.final_machine_type
    vcpus             = local.vcpus
    memory_gb         = local.memory_gb
    disk_size_gb      = local.final_disk_size
    disk_type         = var.disk_type
    edition           = local.final_edition
    region            = var.region
    availability_type = var.availability_type
    backup_enabled    = var.backup_enabled
    preset_used       = var.use_preset_config
  }
}

output "permission_scripts" {
  description = "Generated permission setup scripts"
  value = {
    permissions = var.generate_permission_script ? local_file.permission_script[0].filename : null
    extensions  = length(var.postgresql_extensions) > 0 ? local_file.extensions_script[0].filename : null
  }
}

# ==========================================
# MONITORING URLS
# ==========================================

output "metrics_dashboard_url" {
  description = "URL to the Cloud SQL metrics dashboard"
  value       = "https://console.cloud.google.com/sql/instances/${google_sql_database_instance.postgres.name}/metrics?project=${var.project_id}"
}

output "logs_url" {
  description = "URL to view Cloud SQL logs"
  value       = "https://console.cloud.google.com/logs/query;query=resource.type%3D%22cloudsql_database%22%20resource.labels.database_id%3D%22${var.project_id}:${google_sql_database_instance.postgres.name}%22?project=${var.project_id}"
}

# ==========================================
# POSTGRESQL SPECIFIC INFO
# ==========================================

output "postgres_info" {
  description = "PostgreSQL-specific configuration information"
  value = {
    version    = var.postgres_version
    extensions = var.postgresql_extensions
    performance_flags = var.auto_generate_performance_flags ? {
      shared_buffers       = local.postgres_performance_flags["shared_buffers"]
      effective_cache_size = local.postgres_performance_flags["effective_cache_size"]
      work_mem             = local.postgres_performance_flags["work_mem"]
      maintenance_work_mem = local.postgres_performance_flags["maintenance_work_mem"]
      max_connections      = var.max_connections
      max_parallel_workers = try(local.postgres_performance_flags["max_parallel_workers"], "0")
    } : {}
  }
}
