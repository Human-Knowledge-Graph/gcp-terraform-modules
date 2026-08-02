variable "project_id" {
  description = "The unique ID of the project."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository allowed to authenticate, in 'owner/repo' format. Only this exact repository can impersonate the service account."
  type        = string
}

variable "pool_id" {
  description = "ID for the Workload Identity Pool"
  type        = string
  default     = "github-actions-pool"
}

variable "provider_id" {
  description = "ID for the Workload Identity Pool Provider"
  type        = string
  default     = "github-actions-provider"
}

variable "service_account_id" {
  description = "Account ID (before @) for the service account GitHub Actions will impersonate"
  type        = string
  default     = "github-actions"
}

variable "service_account_display_name" {
  description = "Display name for the service account"
  type        = string
  default     = "GitHub Actions"
}
