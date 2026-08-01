variable "project_id" {
  description = "GCP project ID where the Cloud Tasks queue, log-based metric, notification channel, and alert policy will be created"
  type        = string
}

variable "queue_id" {
  description = "Cloud Tasks queue ID to monitor for high retry counts"
  type        = string
}

variable "notification_email" {
  description = "Email address to notify when a task exceeds the retry threshold"
  type        = string
}

variable "dispatch_count_threshold" {
  description = "Minimum number of dispatches a task must reach before it is counted by the metric and alerted on"
  type        = number
  default     = 100
}

variable "notification_grouping" {
  description = "Whether alert incidents are tracked per individual task_id (\"per_task\") or aggregated across the whole queue (\"per_queue\")"
  type        = string
  default     = "per_task"
}
