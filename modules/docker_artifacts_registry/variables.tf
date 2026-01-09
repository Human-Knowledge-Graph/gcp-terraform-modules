variable "project_id" {
  type        = string
  description = "Google project id"
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
  description = "Tags of artifacts that should be deleted after 1 month"
  default     = ["alpha", "beta"]
}

variable "tags_to_keep_forever" {
  type        = list(string)
  description = "Tags of artifacts to keep until manually deleted"
  default     = ["release"]
}

variable "count_of_versions_to_keep" {
  type        = number
  description = "Determines number of version to keep"
  default     = 1
}