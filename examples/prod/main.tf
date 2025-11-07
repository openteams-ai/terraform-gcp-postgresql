/**
 * Production Example
 *
 * Demonstrates production-ready configuration with high availability,
 * backups, monitoring, and security best practices.
 */

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ==========================================
# CLOUD SQL POSTGRESQL INSTANCE
# ==========================================

module "postgres_prod" {
  source = "../.."

  # Basic configuration
  project_id    = var.project_id
  instance_name = "prod-postgres"
  region        = var.region
  environment   = "production"

  # PostgreSQL version
  postgres_version = "POSTGRES_15"

  # Use performance preset for production
  use_preset_config = "performance"

  # Databases
  databases = {
    production_db = {
      charset   = "UTF8"
      collation = "en_US.UTF8"
    }
  }

  # Users with different access levels
  users = {
    app_admin = {
      role            = "admin"
      password_length = 24
    }
    app_service = {
      role            = "readwrite"
      password_length = 20
    }
    app_readonly = {
      role            = "readonly"
      password_length = 20
    }
  }

  # Network configuration - restrict to specific IPs
  ipv4_enabled = true
  authorized_networks = [
    {
      name = "office-network"
      cidr = var.office_cidr
    },
    {
      name = "gke-cluster"
      cidr = var.gke_cidr
    }
  ]
  ssl_mode = "ENCRYPTED_ONLY"

  # High availability
  availability_type = "REGIONAL"

  # Comprehensive backup configuration
  backup_enabled                 = true
  backup_start_time              = "02:00"
  backup_location                = var.region
  backup_retention_days          = 30
  point_in_time_recovery         = true
  transaction_log_retention_days = 7

  # Read replicas for load distribution
  read_replicas = {
    replica1 = {
      region            = var.replica_region
      availability_type = "ZONAL"
      failover_target   = true
    }
  }

  # Monitoring
  query_insights_enabled  = true
  query_string_length     = 2048
  record_application_tags = true
  record_client_address   = true

  # PostgreSQL performance tuning
  auto_generate_performance_flags = true
  max_connections                 = "500"
  slow_query_threshold_ms         = 1000

  # Security
  deletion_protection               = true
  store_passwords_in_secret_manager = true
  generate_permission_script        = true

  # Maintenance window
  maintenance_window_day  = 1 # Monday
  maintenance_window_hour = 3 # 3 AM

  labels = {
    environment = "production"
    managed_by  = "terraform"
    criticality = "high"
  }
}
