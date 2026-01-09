variable "project_id" {
  type        = string
  description = "Google project id"
}

variable "cleanup_policy_dry_run" {
  type        = bool
  description = "If true, cleanup policies will only log what would be deleted without actually deleting"
  default     = false
}

variable "delete_older_than_days" {
  type        = number
  description = "Number of days after which tagged artifacts should be deleted"
  default     = 30
}

variable "location" {
  type        = string
  description = "Location to store the artifacts"
}

variable "artifacts_repository_id" {
  type        = string
  description = "Name of the artifacts repository"
}

variable "description" {
  type        = string
  description = "Description of the artifacts registry repository"
  default     = ""
}

variable "tags_to_delete_after_a_month" {
  type        = list(string)
  description = "Tags of artifacts to delete after specified days. Empty list means all tags (except those in tags_to_keep_forever)"
  default     = []
}

variable "tags_to_keep_forever" {
  type        = list(string)
  description = "Tags of artifacts to keep until manually deleted"
  default     = ["release", "latest"]
}

variable "count_of_versions_to_keep" {
  type        = number
  description = "Determines number of version to keep"
  default     = 1
}