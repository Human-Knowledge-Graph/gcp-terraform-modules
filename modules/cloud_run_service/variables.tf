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