variable "project_id" {
  description = "GCP project ID where the alert policy will be created"
  type        = string
}

variable "queue_id" {
  description = "Cloud Tasks queue ID this alert monitors. Used for the display name and notification content only — the paired log-based metric is already scoped to this queue via its own filter."
  type        = string
}

variable "metric_name" {
  description = "Full metric type path of the high-retry-tasks log-based metric, e.g. the metric_name output of the log_based_metrics/high_retry_tasks module (logging.googleapis.com/user/<name>)"
  type        = string
}

variable "dispatch_count_threshold" {
  description = "Retry threshold configured on the paired log-based metric. Used for the display name and documentation text only — must match the dispatch_count_threshold passed to the log_based_metrics/high_retry_tasks module."
  type        = number
  default     = 100
}

variable "notification_channels" {
  description = "List of notification channel resource names to notify (e.g. [google_monitoring_notification_channel.email.name]). Not created by this module — pass channels managed elsewhere."
  type        = list(string)
}

variable "notification_grouping" {
  description = "Whether incidents are tracked per individual task_id (\"per_task\", one incident and notification per retrying task) or aggregated across the whole queue (\"per_queue\", one incident for the queue as a whole)"
  type        = string
  default     = "per_task"

  validation {
    condition     = contains(["per_task", "per_queue"], var.notification_grouping)
    error_message = "notification_grouping must be either \"per_task\" or \"per_queue\"."
  }
}

variable "auto_close" {
  description = "Duration after which an open incident auto-closes if no new violating data arrives. In per_task mode this is what prevents renotifying for the same task while it keeps retrying with gaps (e.g. \"86400s\" for once per 24h)."
  type        = string
  default     = "86400s"

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)?s$", var.auto_close))
    error_message = "auto_close must be a Cloud Monitoring duration string in seconds, e.g. \"86400s\"."
  }
}
