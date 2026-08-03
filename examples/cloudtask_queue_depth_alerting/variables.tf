variable "project_id" {
  description = "GCP project ID where the Cloud Tasks queue, notification channel, and alert policy will be created"
  type        = string
}

variable "queue_id" {
  description = "Cloud Tasks queue ID to monitor for elevated queue depth"
  type        = string
}

variable "notification_email" {
  description = "Email address to notify when queue depth stays above the threshold for the configured duration"
  type        = string
}

variable "location" {
  description = "Location (region) of the Cloud Tasks queue, e.g. \"us-central1\". Leave null if queue_id is unique enough within the project."
  type        = string
  default     = null
}

variable "depth_threshold" {
  description = "Queue depth above which the alert fires"
  type        = number
  default     = 200
}

variable "duration" {
  description = "How long queue depth must stay above depth_threshold, continuously, before the alert fires (Cloud Monitoring duration string, e.g. \"7200s\" for 2 hours)"
  type        = string
  default     = "7200s"
}
