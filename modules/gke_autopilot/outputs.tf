output "cluster_name" {
  description = "The name of the GKE Autopilot cluster."
  value       = google_container_cluster.default.name
}

output "cluster_id" {
  description = "The unique identifier of the GKE Autopilot cluster."
  value       = google_container_cluster.default.id
}

output "cluster_location" {
  description = "The region where the cluster is deployed."
  value       = google_container_cluster.default.location
}

output "cluster_endpoint" {
  description = "The IP address of the cluster's Kubernetes API server endpoint."
  value       = google_container_cluster.default.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The base64-encoded public certificate authority for the cluster. Used to authenticate with the Kubernetes API."
  value       = google_container_cluster.default.master_auth[0].cluster_ca_certificate
  sensitive   = true
}
