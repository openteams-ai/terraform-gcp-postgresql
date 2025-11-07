<!-- BEGIN_TF_DOCS -->
Development Example

Demonstrates basic usage of the Cloud SQL PostgreSQL module
with minimal configuration for development/testing purposes.

## Usage

```hcl
module "cloudrun_ai_app" {
  source  = "openteams-ai/cloudrun-ai-app/gcp"
  version = "~> 1.0"

  project_id     = "my-gcp-project"
  region         = "us-central1"
  customer_name  = "acme-corp"
  domain_name    = "acme.example.com"

  # Application configuration
  app_image      = "gcr.io/my-project/ai-app:latest"
  app_env_vars   = {
    AI_BACKEND_URL = "https://api.openai.com/v1"
    MCP_SERVER_URL = "https://mcp.example.com"
  }
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