variable "project_id" {
  description = "The unique ID of the project."
  type        = string
}

variable "region" {
  description = "The region for the project."
  type        = string
  default     = "us-central1"
}



variable "cloud_run_service_name" {
  description = "Name of the default Cloud Run Service"
  type        = string
}


variable "allowed_invoker_members" {
  description = "List of members allowed to invoke the Cloud Run service"
  type        = list(string)
}

variable "env_vars" {
  description = "Environment variables as pairs of key, values"
  type        = map(string)
}

variable "image" {
  description = "Container image location"
  type        = string
}

variable "service_account_email" {
  description = "Service account email to run the Cloud Run service as. If not provided, uses the default Compute Engine service account"
  type        = string
  default     = null
}

variable "cpu_limit" {
  description = "CPU limit for the container (e.g., '1000m' for 1 vCPU, '2000m' for 2 vCPUs)"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for the container (e.g., '256Mi', '512Mi', '1Gi', '2Gi')"
  type        = string
  default     = "512Mi"
}

variable "container_port" {
  description = "Port that the container listens on"
  type        = number
  default     = 8080
}

variable "timeout_seconds" {
  description = "Maximum duration in seconds for each request"
  type        = number
  default     = 300
}

variable "container_concurrency" {
  description = "Maximum number of concurrent requests per container instance"
  type        = number
  default     = 80
}

variable "min_instances" {
  description = "Minimum number of container instances to keep running"
  type        = string
  default     = "0"
}

variable "max_instances" {
  description = "Maximum number of container instances to scale to"
  type        = string
  default     = "100"
}

variable "ingress" {
  description = "Ingress settings for the service: 'all', 'internal', or 'internal-and-cloud-load-balancing'"
  type        = string
  default     = "all"

  validation {
    condition     = contains(["all", "internal", "internal-and-cloud-load-balancing"], var.ingress)
    error_message = "Ingress must be one of: 'all', 'internal', or 'internal-and-cloud-load-balancing'."
  }
}