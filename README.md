# Cloud SQL PostgreSQL Module

A reusable Terraform/OpenTofu module for deploying Google Cloud SQL PostgreSQL instances
with support for multiple databases and users with different permission levels.

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform.yml    # CI/CD pipeline
├── .pre-commit-config.yaml  # Pre-commit hook configuration
├── .terraform-docs.yml      # Terraform docs configuration
├── .tflint.hcl             # TFLint configuration
├── examples/               # Usage examples
│   ├── dev/               # Development environment example
│   └── prod/              # Production environment example
├── test/                  # Terratest suite
│   ├── go.mod            # Go module definition
│   └── module_test.go    # Test implementation
├── Makefile              # Development commands
├── main.tf               # Main module configuration (to be created)
├── variables.tf          # Input variables (to be created)
├── outputs.tf            # Output definitions (to be created)
├── versions.tf           # Provider version constraints (to be created)
└── README.md            # This file
```

## Module Documentation

The following section contains auto-generated documentation for this Terraform module using terraform-docs:

<!-- BEGIN_TF_DOCS -->
# Cloud SQL PostgreSQL Module

A reusable Terraform/OpenTofu module for deploying Google Cloud SQL PostgreSQL instances
with support for multiple databases and users with different permission levels.

## Features
- Multiple database support
- Configurable user roles (admin, read-write, read-only, custom)
- Preset configurations (budget, balanced, performance)
- Automatic password generation and Secret Manager integration
- PostgreSQL-specific performance tuning
- Read replica configuration
- Performance monitoring with pg\_stat\_statements

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
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.10.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.3 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_secret_manager_secret.user_passwords](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.user_passwords](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_sql_database.databases](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.postgres](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_database_instance.read_replicas](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.users](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [local_file.extensions_script](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.permission_script](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_id.instance_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.user_passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_database_flags"></a> [additional\_database\_flags](#input\_additional\_database\_flags) | Additional PostgreSQL configuration flags | `map(string)` | `{}` | no |
| <a name="input_authorized_networks"></a> [authorized\_networks](#input\_authorized\_networks) | List of authorized networks for IP whitelisting | <pre>list(object({<br/>    name = string<br/>    cidr = string<br/>  }))</pre> | `[]` | no |
| <a name="input_auto_generate_performance_flags"></a> [auto\_generate\_performance\_flags](#input\_auto\_generate\_performance\_flags) | Automatically generate PostgreSQL performance tuning flags based on instance size | `bool` | `true` | no |
| <a name="input_availability_type"></a> [availability\_type](#input\_availability\_type) | Availability type: ZONAL or REGIONAL | `string` | `"ZONAL"` | no |
| <a name="input_backup_enabled"></a> [backup\_enabled](#input\_backup\_enabled) | Enable automated backups | `bool` | `true` | no |
| <a name="input_backup_location"></a> [backup\_location](#input\_backup\_location) | Location for backups | `string` | `null` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Number of backup retention days | `number` | `30` | no |
| <a name="input_backup_start_time"></a> [backup\_start\_time](#input\_backup\_start\_time) | HH:MM format time for backup window | `string` | `"02:00"` | no |
| <a name="input_config_presets"></a> [config\_presets](#input\_config\_presets) | Preset configurations for different use cases | <pre>map(object({<br/>    machine_type = string<br/>    disk_size    = number<br/>    edition      = string<br/>  }))</pre> | <pre>{<br/>  "balanced": {<br/>    "disk_size": 500,<br/>    "edition": "ENTERPRISE",<br/>    "machine_type": "db-custom-4-16384"<br/>  },<br/>  "budget": {<br/>    "disk_size": 100,<br/>    "edition": "ENTERPRISE",<br/>    "machine_type": "db-custom-2-7680"<br/>  },<br/>  "performance": {<br/>    "disk_size": 1000,<br/>    "edition": "ENTERPRISE_PLUS",<br/>    "machine_type": "db-custom-8-32768"<br/>  }<br/>}</pre> | no |
| <a name="input_connector_enforcement"></a> [connector\_enforcement](#input\_connector\_enforcement) | Enforce use of Cloud SQL connector | `string` | `"NOT_REQUIRED"` | no |
| <a name="input_data_cache_enabled"></a> [data\_cache\_enabled](#input\_data\_cache\_enabled) | Enable data cache (Enterprise Plus only) | `bool` | `true` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | Map of databases to create with optional charset and collation | <pre>map(object({<br/>    charset   = optional(string)<br/>    collation = optional(string)<br/>  }))</pre> | <pre>{<br/>  "main": {}<br/>}</pre> | no |
| <a name="input_default_password_length"></a> [default\_password\_length](#input\_default\_password\_length) | Default length for generated passwords | `number` | `16` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable deletion protection | `bool` | `false` | no |
| <a name="input_deny_maintenance_periods"></a> [deny\_maintenance\_periods](#input\_deny\_maintenance\_periods) | List of deny maintenance periods | <pre>list(object({<br/>    start_date = string<br/>    end_date   = string<br/>    time       = string<br/>  }))</pre> | `[]` | no |
| <a name="input_disk_autoresize"></a> [disk\_autoresize](#input\_disk\_autoresize) | Enable automatic storage increase | `bool` | `true` | no |
| <a name="input_disk_autoresize_limit_gb"></a> [disk\_autoresize\_limit\_gb](#input\_disk\_autoresize\_limit\_gb) | Maximum disk size when autoresize is enabled (0 = unlimited) | `number` | `0` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Initial disk size in GB | `number` | `100` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Type of disk: PD\_SSD or PD\_HDD | `string` | `"PD_SSD"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, production) | `string` | `"dev"` | no |
| <a name="input_generate_permission_script"></a> [generate\_permission\_script](#input\_generate\_permission\_script) | Generate SQL script for setting up user permissions | `bool` | `true` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Base name for the Cloud SQL PostgreSQL instance | `string` | n/a | yes |
| <a name="input_ipv4_enabled"></a> [ipv4\_enabled](#input\_ipv4\_enabled) | Enable IPv4 connectivity | `bool` | `true` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to resources | `map(string)` | `{}` | no |
| <a name="input_log_all_statements"></a> [log\_all\_statements](#input\_log\_all\_statements) | Log all SQL statements (use with caution in production) | `bool` | `false` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for the instance (used when use\_preset\_config is 'custom') | `string` | `"db-custom-4-16384"` | no |
| <a name="input_maintenance_window_day"></a> [maintenance\_window\_day](#input\_maintenance\_window\_day) | Day of week for maintenance window (1-7, 1 = Monday) | `number` | `7` | no |
| <a name="input_maintenance_window_hour"></a> [maintenance\_window\_hour](#input\_maintenance\_window\_hour) | Hour of day for maintenance window (0-23) | `number` | `3` | no |
| <a name="input_maintenance_window_update_track"></a> [maintenance\_window\_update\_track](#input\_maintenance\_window\_update\_track) | Update track: stable or canary | `string` | `"stable"` | no |
| <a name="input_max_connections"></a> [max\_connections](#input\_max\_connections) | Maximum number of connections | `string` | `"200"` | no |
| <a name="input_point_in_time_recovery"></a> [point\_in\_time\_recovery](#input\_point\_in\_time\_recovery) | Enable point-in-time recovery | `bool` | `true` | no |
| <a name="input_postgres_version"></a> [postgres\_version](#input\_postgres\_version) | PostgreSQL version | `string` | `"POSTGRES_15"` | no |
| <a name="input_postgresql_extensions"></a> [postgresql\_extensions](#input\_postgresql\_extensions) | List of PostgreSQL extensions to enable | `list(string)` | <pre>[<br/>  "pg_stat_statements",<br/>  "pgcrypto",<br/>  "uuid-ossp"<br/>]</pre> | no |
| <a name="input_pricing_plan"></a> [pricing\_plan](#input\_pricing\_plan) | Pricing plan: PER\_USE or PACKAGE | `string` | `"PER_USE"` | no |
| <a name="input_private_network_id"></a> [private\_network\_id](#input\_private\_network\_id) | VPC network ID for private IP connectivity | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID where resources will be created | `string` | n/a | yes |
| <a name="input_query_insights_enabled"></a> [query\_insights\_enabled](#input\_query\_insights\_enabled) | Enable Query Insights for performance monitoring | `bool` | `true` | no |
| <a name="input_query_plans_per_minute"></a> [query\_plans\_per\_minute](#input\_query\_plans\_per\_minute) | Number of query plans to sample per minute | `number` | `5` | no |
| <a name="input_query_string_length"></a> [query\_string\_length](#input\_query\_string\_length) | Maximum query string length to log | `number` | `1024` | no |
| <a name="input_random_suffix_length"></a> [random\_suffix\_length](#input\_random\_suffix\_length) | Length of random suffix in bytes | `number` | `4` | no |
| <a name="input_read_replicas"></a> [read\_replicas](#input\_read\_replicas) | Map of read replicas to create | <pre>map(object({<br/>    region            = optional(string)<br/>    machine_type      = optional(string)<br/>    disk_size         = optional(number)<br/>    availability_type = optional(string)<br/>    failover_target   = optional(bool)<br/>    database_flags    = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_record_application_tags"></a> [record\_application\_tags](#input\_record\_application\_tags) | Record application tags in Query Insights | `bool` | `true` | no |
| <a name="input_record_client_address"></a> [record\_client\_address](#input\_record\_client\_address) | Record client address in Query Insights | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | The GCP region for the Cloud SQL instance | `string` | n/a | yes |
| <a name="input_slow_query_threshold_ms"></a> [slow\_query\_threshold\_ms](#input\_slow\_query\_threshold\_ms) | Log queries slower than this threshold (milliseconds) | `number` | `1000` | no |
| <a name="input_sql_edition"></a> [sql\_edition](#input\_sql\_edition) | Cloud SQL edition: ENTERPRISE or ENTERPRISE\_PLUS | `string` | `"ENTERPRISE"` | no |
| <a name="input_ssl_mode"></a> [ssl\_mode](#input\_ssl\_mode) | SSL mode: ALLOW\_UNENCRYPTED\_AND\_ENCRYPTED, ENCRYPTED\_ONLY, or TRUSTED\_CLIENT\_CERTIFICATE\_REQUIRED | `string` | `"ENCRYPTED_ONLY"` | no |
| <a name="input_store_passwords_in_secret_manager"></a> [store\_passwords\_in\_secret\_manager](#input\_store\_passwords\_in\_secret\_manager) | Store generated passwords in Google Secret Manager | `bool` | `true` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeout configurations for resource operations | <pre>object({<br/>    create = optional(string, "30m")<br/>    update = optional(string, "30m")<br/>    delete = optional(string, "30m")<br/>  })</pre> | `{}` | no |
| <a name="input_transaction_log_retention_days"></a> [transaction\_log\_retention\_days](#input\_transaction\_log\_retention\_days) | Number of days to retain transaction logs | `number` | `7` | no |
| <a name="input_use_preset_config"></a> [use\_preset\_config](#input\_use\_preset\_config) | Use preset configuration (budget, balanced, performance, or custom) | `string` | `"balanced"` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Add random suffix to instance name for uniqueness | `bool` | `true` | no |
| <a name="input_users"></a> [users](#input\_users) | Map of users to create with their configuration | <pre>map(object({<br/>    role                 = optional(string, "readonly") # admin, readwrite, readonly, custom<br/>    password             = optional(string)             # If not provided, will be generated<br/>    password_length      = optional(number)<br/>    password_special     = optional(bool)<br/>    password_min_upper   = optional(number)<br/>    password_min_lower   = optional(number)<br/>    password_min_numeric = optional(number)<br/>    password_min_special = optional(number)<br/>    custom_grants        = optional(map(list(string))) # For custom role: map of database to list of grants<br/>  }))</pre> | <pre>{<br/>  "app_user": {<br/>    "role": "readwrite"<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_sql_proxy_command"></a> [cloud\_sql\_proxy\_command](#output\_cloud\_sql\_proxy\_command) | Command to start Cloud SQL proxy for PostgreSQL |
| <a name="output_configuration"></a> [configuration](#output\_configuration) | Current configuration of the PostgreSQL instance |
| <a name="output_connection_strings"></a> [connection\_strings](#output\_connection\_strings) | PostgreSQL connection strings for different scenarios |
| <a name="output_database_names"></a> [database\_names](#output\_database\_names) | List of database names |
| <a name="output_databases"></a> [databases](#output\_databases) | Map of created databases |
| <a name="output_instance_connection_name"></a> [instance\_connection\_name](#output\_instance\_connection\_name) | The connection name for the Cloud SQL instance (project:region:instance) |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | The name of the Cloud SQL PostgreSQL instance |
| <a name="output_instance_self_link"></a> [instance\_self\_link](#output\_instance\_self\_link) | The self link of the Cloud SQL instance |
| <a name="output_instance_service_account_email"></a> [instance\_service\_account\_email](#output\_instance\_service\_account\_email) | The service account email associated with the instance |
| <a name="output_logs_url"></a> [logs\_url](#output\_logs\_url) | URL to view Cloud SQL logs |
| <a name="output_metrics_dashboard_url"></a> [metrics\_dashboard\_url](#output\_metrics\_dashboard\_url) | URL to the Cloud SQL metrics dashboard |
| <a name="output_permission_scripts"></a> [permission\_scripts](#output\_permission\_scripts) | Generated permission setup scripts |
| <a name="output_postgres_info"></a> [postgres\_info](#output\_postgres\_info) | PostgreSQL-specific configuration information |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | The private IP address assigned to the instance |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | The public IPv4 address assigned to the instance |
| <a name="output_read_replicas"></a> [read\_replicas](#output\_read\_replicas) | Map of read replica information |
| <a name="output_user_passwords"></a> [user\_passwords](#output\_user\_passwords) | Map of user passwords (sensitive) |
| <a name="output_user_secret_ids"></a> [user\_secret\_ids](#output\_user\_secret\_ids) | Map of Secret Manager secret IDs for user passwords |
| <a name="output_users"></a> [users](#output\_users) | Map of created users with their details |
<!-- END_TF_DOCS -->

## Documentation Maintenance

This README uses terraform-docs to automatically generate and maintain module documentation. The content between `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` is automatically generated.

### How to Update Documentation

1. **Auto-generate**: Run `make docs` to update the terraform-docs section
2. **Manual content**: Edit sections outside the terraform-docs markers
3. **Configuration**: Modify `.terraform-docs.yml` to customize the generated content

### terraform-docs Workflow

- The `make docs` command uses Docker to run terraform-docs
- It reads your Terraform files (main.tf, variables.tf, outputs.tf, etc.)
- Generates documentation in Markdown format
- Injects the content between the `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` markers
- Preserves all custom content outside these markers

**Important**: Never manually edit content between the terraform-docs markers as it will be overwritten.

## Testing

This template includes comprehensive testing setup using Terratest. The tests validate:

- Infrastructure provisioning
- Resource configuration
- Input validation
- Multi-environment scenarios

### Test Structure

The template includes three types of tests:

1. **Terraform Validation**: Tests that the main module can be initialized and validated
2. **Examples Validation**: Tests that example configurations are syntactically correct
3. **Module Functionality**: Placeholder tests that demonstrate assertion patterns

**Note**: These are validation-only tests that don't deploy actual infrastructure. When developing your module, replace the placeholder tests with actual functionality tests as needed.

### Running Tests

```bash
# Run all tests
make test

# Run specific test functions
cd test && go test -v -run TestDevExample
```

## Makefile Commands

| Command         | Description                                      |
| --------------- | ------------------------------------------------ |
| `make help`     | Display available make targets with descriptions |
| `make init`     | Initialize OpenTofu and install pre-commit hooks |
| `make fmt`      | Format all Terraform files                       |
| `make validate` | Validate Terraform configuration                 |
| `make lint`     | Run all linting checks                           |
| `make test`     | Run the full test suite                          |
| `make docs`     | Generate documentation with terraform-docs       |
| `make clean`    | Clean up temporary files and directories         |
