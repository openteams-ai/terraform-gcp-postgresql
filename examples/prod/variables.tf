variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for primary instance"
  type        = string
  default     = "us-central1"
}

variable "replica_region" {
  description = "GCP region for read replica"
  type        = string
  default     = "us-east1"
}

variable "office_cidr" {
  description = "CIDR block for office network"
  type        = string
}

variable "gke_cidr" {
  description = "CIDR block for GKE cluster"
  type        = string
}
