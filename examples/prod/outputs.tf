output "instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = module.postgres_prod.instance_name
}

output "instance_connection_name" {
  description = "The connection name for the Cloud SQL instance"
  value       = module.postgres_prod.instance_connection_name
}

output "public_ip_address" {
  description = "The public IP address of the instance"
  value       = module.postgres_prod.public_ip_address
}

output "private_ip_address" {
  description = "The private IP address of the instance"
  value       = module.postgres_prod.private_ip_address
}

output "databases" {
  description = "Created databases"
  value       = module.postgres_prod.database_names
}

output "read_replicas" {
  description = "Read replica information"
  value       = module.postgres_prod.read_replicas
}

output "cloud_sql_proxy_command" {
  description = "Command to connect via Cloud SQL proxy"
  value       = module.postgres_prod.cloud_sql_proxy_command
}

output "metrics_dashboard_url" {
  description = "URL to the Cloud SQL metrics dashboard"
  value       = module.postgres_prod.metrics_dashboard_url
}

output "user_secret_ids" {
  description = "Secret Manager secret IDs for user passwords"
  value       = module.postgres_prod.user_secret_ids
}
