/**
 * Development Example
 *
 * Demonstrates basic usage of the Cloud SQL PostgreSQL module
 * with minimal configuration for development/testing purposes.
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

module "postgres_dev" {
  source = "../.."

  # Basic configuration
  project_id    = var.project_id
  instance_name = "dev-postgres-demo"
  region        = var.region
  environment   = "dev"

  # PostgreSQL version
  postgres_version = "POSTGRES_15"

  # Use budget preset for development
  use_preset_config = "budget"

  # Databases
  databases = {
    app_db = {
      charset   = "UTF8"
      collation = "en_US.UTF8"
    }
    test_db = {}
  }

  # Users with different access levels
  users = {
    app_admin = {
      role = "admin"
    }
    app_user = {
      role = "readwrite"
    }
    app_readonly = {
      role = "readonly"
    }
  }

  # Network configuration - allow from anywhere for dev (CHANGE FOR PRODUCTION!)
  ipv4_enabled = true
  authorized_networks = [
    {
      name = "allow-all-dev"
      cidr = "0.0.0.0/0"
    }
  ]

  # Development settings
  availability_type      = "ZONAL"
  backup_enabled         = true
  deletion_protection    = false
  query_insights_enabled = true

  # PostgreSQL performance tuning
  auto_generate_performance_flags = true
  max_connections                 = "200"

  # Store passwords in Secret Manager
  store_passwords_in_secret_manager = true
  generate_permission_script        = true

  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }
}
