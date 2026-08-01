output "metric_name" {
  description = "Full metric type path of the log-based metric backing the alert"
  value       = module.high_retry_tasks_metric.metric_name
}

output "notification_channel_id" {
  description = "Resource name of the email notification channel"
  value       = google_monitoring_notification_channel.email.name
}

output "alert_policy_id" {
  description = "Fully qualified identifier of the alert policy"
  value       = module.high_retry_tasks_alert.alert_policy_id
}
