variable "metrics_scope_project_id" {
  description = "Project ID of the central Cloud Monitoring metrics scope (host project)"
  type        = string
}

variable "monitored_project_ids" {
  description = "Set of project IDs whose metrics should be visible in the metrics scope"
  type        = set(string)
}
