output "notification_channel_id" {
  description = "Resource name of the email notification channel"
  value       = google_monitoring_notification_channel.email.name
}

output "alert_policy_id" {
  description = "Fully qualified identifier of the alert policy"
  value       = module.queue_depth_alert.alert_policy_id
}
