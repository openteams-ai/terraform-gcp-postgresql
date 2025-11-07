output "instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = module.postgres_dev.instance_name
}

output "instance_connection_name" {
  description = "The connection name for the Cloud SQL instance"
  value       = module.postgres_dev.instance_connection_name
}

output "public_ip_address" {
  description = "The public IP address of the instance"
  value       = module.postgres_dev.public_ip_address
}

output "databases" {
  description = "Created databases"
  value       = module.postgres_dev.database_names
}

output "cloud_sql_proxy_command" {
  description = "Command to connect via Cloud SQL proxy"
  value       = module.postgres_dev.cloud_sql_proxy_command
}

output "metrics_dashboard_url" {
  description = "URL to the Cloud SQL metrics dashboard"
  value       = module.postgres_dev.metrics_dashboard_url
}
