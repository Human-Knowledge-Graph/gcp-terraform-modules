variable "project_id" {
  description = "GCP project ID where the Cloud Tasks queue and log-based metric reside"
  type        = string
}

variable "queue_id" {
  description = "Cloud Tasks queue ID to monitor"
  type        = string
}

variable "metric_name" {
  description = "Name of the log-based metric (must be unique within the project)"
  type        = string
  default     = "cloudtasks_high_retry_count"
}

variable "dispatch_count_threshold" {
  description = "Minimum number of dispatches a task must have reached to be counted by this metric. Tasks at or above this value are included."
  type        = number
  default     = 100
}
