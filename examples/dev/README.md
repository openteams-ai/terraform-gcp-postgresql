<!-- BEGIN_TF_DOCS -->
Development Example

Demonstrates basic usage of the Cloud SQL PostgreSQL module
with minimal configuration for development/testing purposes.

Features demonstrated:
- Budget preset configuration (2 vCPUs, 7.5GB RAM, 100GB disk)
- Multiple databases (app\_db, test\_db)
- Multiple user roles (admin, readwrite, readonly)
- Open network access for development (NOT for production!)
- Automated password generation and Secret Manager storage
- Query insights for performance monitoring
- PostgreSQL performance auto-tuning

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
| <a name="module_postgres_dev"></a> [postgres\_dev](#module\_postgres\_dev) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region for deployment | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_sql_proxy_command"></a> [cloud\_sql\_proxy\_command](#output\_cloud\_sql\_proxy\_command) | Command to connect via Cloud SQL proxy |
| <a name="output_databases"></a> [databases](#output\_databases) | Created databases |
| <a name="output_instance_connection_name"></a> [instance\_connection\_name](#output\_instance\_connection\_name) | The connection name for the Cloud SQL instance |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | The name of the Cloud SQL instance |
| <a name="output_metrics_dashboard_url"></a> [metrics\_dashboard\_url](#output\_metrics\_dashboard\_url) | URL to the Cloud SQL metrics dashboard |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | The public IP address of the instance |
<!-- END_TF_DOCS -->
