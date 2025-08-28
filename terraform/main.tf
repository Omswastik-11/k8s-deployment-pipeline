provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

# GKE Cluster for staging
resource "google_container_cluster" "staging" {
  name     = "staging-cluster"
  location = "${var.region}-a"

  initial_node_count = 1
  deletion_protection = false

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 20

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# GKE Cluster for production
resource "google_container_cluster" "production" {
  name     = "prod-cluster"
  location = "${var.region}-a"

  initial_node_count = 2
  deletion_protection = true

  node_config {
    machine_type = "e2-standard-2"
    disk_size_gb = 50

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

output "staging_cluster_endpoint" {
  value = google_container_cluster.staging.endpoint
}

output "production_cluster_endpoint" {
  value = google_container_cluster.production.endpoint
}