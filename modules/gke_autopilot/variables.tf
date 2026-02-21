variable "project_id" {
  description = "The unique ID of the GCP project."
  type        = string
}

variable "region" {
  description = "The region where the GKE Autopilot cluster will be created. Autopilot clusters are always regional (not zonal)."
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE Autopilot cluster."
  type        = string
}

variable "network" {
  description = "The name or self-link of the VPC network to use for the cluster."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The name or self-link of the subnetwork to use for the cluster."
  type        = string
  default     = "default"
}

variable "release_channel" {
  description = "The release channel for GKE version updates: 'RAPID', 'REGULAR', or 'STABLE'."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "Release channel must be one of: 'RAPID', 'REGULAR', or 'STABLE'."
  }
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the cluster. Set to false to allow Terraform to destroy the cluster."
  type        = bool
  default     = false
}
