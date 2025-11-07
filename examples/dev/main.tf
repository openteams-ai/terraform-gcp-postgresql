/**
 * Development Example
 *
 * Demonstrates basic usage of the Cloud SQL PostgreSQL module
 * with minimal configuration for development/testing purposes.
 *
 * Features demonstrated:
 * - Budget preset configuration (2 vCPUs, 7.5GB RAM, 100GB disk)
 * - Multiple databases (app_db, test_db)
 * - Multiple user roles (admin, readwrite, readonly)
 * - Open network access for development (NOT for production!)
 * - Automated password generation and Secret Manager storage
 * - Query insights for performance monitoring
 * - PostgreSQL performance auto-tuning
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
# CLOUD SQL POSTGRESQL INSTANCE - DEV
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

  # Use budget preset for development (2 vCPUs, 7.5GB RAM, 100GB disk, ENTERPRISE)
  use_preset_config = "budget"

  # Create multiple databases
  databases = {
    app_db = {
      charset   = "UTF8"
      collation = "en_US.UTF8"
    }
    test_db = {
      charset   = "UTF8"
      collation = "en_US.UTF8"
    }
  }

  # Create users with different access levels
  users = {
    app_admin = {
      role = "admin" # Full database access
    }
    app_user = {
      role = "readwrite" # Can read and write data
    }
    app_readonly = {
      role = "readonly" # Can only read data
    }
  }

  # Network configuration
  # WARNING: Open access (0.0.0.0/0) is for development only!
  # NEVER use this in production - restrict to specific IPs/ranges
  ipv4_enabled = true
  authorized_networks = [
    {
      name = "allow-all-dev"
      cidr = "0.0.0.0/0"
    }
  ]

  # Development-appropriate settings
  availability_type     = "ZONAL" # Single zone (cheaper for dev)
  backup_enabled        = true    # Enable backups
  deletion_protection   = false   # Allow easy cleanup for dev
  backup_retention_days = 7       # Keep 7 days of backups (vs 30 for prod)

  # Monitoring and performance
  query_insights_enabled          = true
  auto_generate_performance_flags = true
  max_connections                 = "200"

  # Password management
  store_passwords_in_secret_manager = true # Store passwords in Secret Manager
  generate_permission_script        = true # Generate SQL script for permissions

  # PostgreSQL extensions (optional)
  postgresql_extensions = [
    "pg_stat_statements", # Query performance monitoring
    "pgcrypto",           # Cryptographic functions
    "uuid-ossp"           # UUID generation
  ]

  labels = {
    environment = "dev"
    managed_by  = "terraform"
    team        = "engineering"
  }
}
