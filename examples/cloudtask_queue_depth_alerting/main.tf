resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "Cloud Tasks queue depth alerts"
  type         = "email"

  labels = {
    email_address = var.notification_email
  }
}

module "queue_depth_alert" {
  source = "../../modules/observability/cloudtask/alerting/queue_depth"

  project_id            = var.project_id
  queue_id              = var.queue_id
  location              = var.location
  depth_threshold       = var.depth_threshold
  duration              = var.duration
  notification_channels = [google_monitoring_notification_channel.email.name]
}
