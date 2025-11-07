/**
 * Production Example
 *
 * Demonstrates production-ready configuration with high availability,
 * backups, monitoring, and security best practices.
 *
 * Features demonstrated:
 * - Performance preset (8 vCPUs, 32GB RAM, 1TB disk, ENTERPRISE_PLUS)
 * - Regional high availability for automatic failover
 * - Read replicas for load distribution and disaster recovery
 * - Restricted network access to specific CIDR ranges
 * - SSL/TLS encryption enforcement
 * - Comprehensive backup and point-in-time recovery
 * - Extended query insights and monitoring
 * - Stronger password requirements
 * - Deletion protection enabled
 * - Maintenance window scheduling
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
# CLOUD SQL POSTGRESQL INSTANCE - PRODUCTION
# ==========================================

module "postgres_prod" {
  source = "../.."

  # Basic configuration
  project_id    = var.project_id
  instance_name = "prod-postgres"
  region        = var.region
  environment   = "production"

  # PostgreSQL version - use latest stable
  postgres_version = "POSTGRES_15"

  # Use performance preset for production (8 vCPUs, 32GB RAM, 1TB disk, ENTERPRISE_PLUS)
  # This includes data cache and other advanced features
  use_preset_config = "performance"

  # Create production database
  databases = {
    production_db = {
      charset   = "UTF8"
      collation = "en_US.UTF8"
    }
  }

  # Create users with strong passwords
  users = {
    app_admin = {
      role            = "admin" # Full database access for administration
      password_length = 24      # Longer password for admin
    }
    app_service = {
      role            = "readwrite" # Application service account
      password_length = 20
    }
    app_readonly = {
      role            = "readonly" # For reporting and analytics
      password_length = 20
    }
  }

  # Network Security
  # Restrict access to known networks only (office and GKE cluster)
  ipv4_enabled = true
  authorized_networks = [
    {
      name = "office-network"
      cidr = var.office_cidr # Office VPN or static IP range
    },
    {
      name = "gke-cluster"
      cidr = var.gke_cidr # GKE cluster pod CIDR
    }
  ]
  ssl_mode = "ENCRYPTED_ONLY" # Enforce SSL/TLS encryption

  # High Availability
  # REGIONAL provides automatic failover within the region
  availability_type = "REGIONAL"

  # Comprehensive Backup Configuration
  backup_enabled                 = true
  backup_start_time              = "02:00"    # 2 AM daily backups
  backup_location                = var.region # Store in same region
  backup_retention_days          = 30         # Keep 30 days of backups
  point_in_time_recovery         = true       # Enable PITR
  transaction_log_retention_days = 7          # 7 days for PITR

  # Read Replicas
  # Deploy read replica in different region for load distribution and DR
  read_replicas = {
    replica1 = {
      region            = var.replica_region # Different region for DR
      availability_type = "ZONAL"            # ZONAL is sufficient for read replica
      failover_target   = false              # Not a failover target (use for reads only)
    }
  }

  # Query Insights and Monitoring
  query_insights_enabled  = true
  query_string_length     = 2048 # Capture longer queries
  record_application_tags = true # Track application context
  record_client_address   = true # Track client IPs

  # PostgreSQL Performance Tuning
  auto_generate_performance_flags = true  # Auto-tune based on instance size
  max_connections                 = "500" # Support more connections
  slow_query_threshold_ms         = 1000  # Log queries slower than 1 second

  # Security and Data Protection
  deletion_protection               = true # Prevent accidental deletion
  store_passwords_in_secret_manager = true # Store passwords securely
  generate_permission_script        = true # Generate SQL permission scripts

  # PostgreSQL Extensions
  postgresql_extensions = [
    "pg_stat_statements", # Query performance monitoring
    "pgcrypto",           # Cryptographic functions
    "uuid-ossp"           # UUID generation
  ]

  # Maintenance Window
  # Schedule maintenance for low-traffic period
  maintenance_window_day  = 1 # Monday
  maintenance_window_hour = 3 # 3 AM

  # Resource Labels
  labels = {
    environment = "production"
    managed_by  = "terraform"
    criticality = "high"
    team        = "platform"
    cost_center = "engineering"
  }
}
