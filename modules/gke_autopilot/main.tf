resource "google_container_cluster" "default" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # Autopilot manages nodes automatically; you only pay for pod resources.
  # GKE waives the $0.10/hr cluster management fee for one Autopilot or
  # Zonal Standard cluster per billing account (~$74.40/month credit).
  enable_autopilot = true

  deletion_protection = var.deletion_protection

  network    = var.network
  subnetwork = var.subnetwork

  release_channel {
    channel = var.release_channel
  }

  # Required for Autopilot (VPC-native). Leave empty to use auto-assigned ranges.
  ip_allocation_policy {}
}
