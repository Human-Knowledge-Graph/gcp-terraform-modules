module "high_retry_tasks_metric" {
  source = "../../modules/observability/cloudtask/log_based_metrics/high_retry_tasks"

  project_id               = var.project_id
  queue_id                 = var.queue_id
  dispatch_count_threshold = var.dispatch_count_threshold
}

resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "Cloud Tasks high retry alerts"
  type         = "email"

  labels = {
    email_address = var.notification_email
  }
}

module "high_retry_tasks_alert" {
  source = "../../modules/observability/cloudtask/alerting/high_retry_tasks"

  project_id               = var.project_id
  queue_id                 = var.queue_id
  metric_name              = module.high_retry_tasks_metric.metric_name
  dispatch_count_threshold = var.dispatch_count_threshold
  notification_channels    = [google_monitoring_notification_channel.email.name]
  notification_grouping    = var.notification_grouping
}
