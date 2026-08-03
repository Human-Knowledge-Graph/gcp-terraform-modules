variable "project_id" {
  description = "GCP project ID where the Cloud Tasks queue resides and the alert policy will be created"
  type        = string
}

variable "queue_id" {
  description = "Cloud Tasks queue ID this alert monitors"
  type        = string
}

variable "location" {
  description = "Location (region) of the Cloud Tasks queue, e.g. \"us-central1\". If set, scopes the alert filter to this location; leave null if queue_id is unique enough within the project."
  type        = string
  default     = null
}

variable "depth_threshold" {
  description = "Queue depth (number of pending/retrying tasks) above which the alert fires"
  type        = number
  default     = 200
}

variable "duration" {
  description = "How long queue depth must stay above depth_threshold, continuously, before the alert fires (Cloud Monitoring duration string, e.g. \"7200s\" for 2 hours)"
  type        = string
  default     = "7200s"
}

variable "alignment_period" {
  description = "Alignment period for sampling queue depth before comparing against depth_threshold (Cloud Monitoring duration string). Used with ALIGN_MAX, so the max depth observed within each period is what gets compared against the threshold."
  type        = string
  default     = "300s"
}

variable "notification_channels" {
  description = "List of notification channel resource names to notify (e.g. [google_monitoring_notification_channel.email.name]). Not created by this module — pass channels managed elsewhere."
  type        = list(string)
}

variable "auto_close" {
  description = "Duration after which an open incident auto-closes if no new data arrives for the queue depth metric (e.g. \"86400s\" for 24h)"
  type        = string
  default     = "86400s"
}
