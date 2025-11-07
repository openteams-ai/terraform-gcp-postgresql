<!-- BEGIN_TF_DOCS -->
Production Example

Demonstrates production-ready configuration with high availability,
backups, monitoring, and security best practices.

Features demonstrated:
- Performance preset (8 vCPUs, 32GB RAM, 1TB disk, ENTERPRISE\_PLUS)
- Regional high availability for automatic failover
- Read replicas for load distribution and disaster recovery
- Restricted network access to specific CIDR ranges
- SSL/TLS encryption enforcement
- Comprehensive backup and point-in-time recovery
- Extended query insights and monitoring
- Stronger password requirements
- Deletion protection enabled
- Maintenance window scheduling

## Usage

```hcl
module "postgres" {
  source = "path/to/terraform-gcp-postgresql"

  project_id    = "my-gcp-project"
  instance_name = "my-postgres-db"
  region        = "us-central1"

  # Use a preset configuration
  use_preset_config = "balanced"

  # Create databases
  databases = {
    app_db = {
      charset   = "UTF8"
      collation = "en_US.UTF8"
    }
  }

  # Create users with different roles
  users = {
    admin_user = {
      role = "admin"
    }
    app_user = {
      role = "readwrite"
    }
    readonly_user = {
      role = "readonly"
    }
  }

  # Network configuration
  authorized_networks = [
    {
      name = "office"
      cidr = "203.0.113.0/24"
    }
  ]

  # Enable automatic password storage
  store_passwords_in_secret_manager = true
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_postgres_prod"></a> [postgres\_prod](#module\_postgres\_prod) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gke_cidr"></a> [gke\_cidr](#input\_gke\_cidr) | CIDR block for GKE cluster | `string` | n/a | yes |
| <a name="input_office_cidr"></a> [office\_cidr](#input\_office\_cidr) | CIDR block for office network | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region for primary instance | `string` | `"us-central1"` | no |
| <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region) | GCP region for read replica | `string` | `"us-east1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_sql_proxy_command"></a> [cloud\_sql\_proxy\_command](#output\_cloud\_sql\_proxy\_command) | Command to connect via Cloud SQL proxy |
| <a name="output_databases"></a> [databases](#output\_databases) | Created databases |
| <a name="output_instance_connection_name"></a> [instance\_connection\_name](#output\_instance\_connection\_name) | The connection name for the Cloud SQL instance |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | The name of the Cloud SQL instance |
| <a name="output_metrics_dashboard_url"></a> [metrics\_dashboard\_url](#output\_metrics\_dashboard\_url) | URL to the Cloud SQL metrics dashboard |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | The private IP address of the instance |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | The public IP address of the instance |
| <a name="output_read_replicas"></a> [read\_replicas](#output\_read\_replicas) | Read replica information |
| <a name="output_user_secret_ids"></a> [user\_secret\_ids](#output\_user\_secret\_ids) | Secret Manager secret IDs for user passwords |
<!-- END_TF_DOCS -->
