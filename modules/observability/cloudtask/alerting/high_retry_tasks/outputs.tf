output "alert_policy_id" {
  description = "Fully qualified identifier of the alert policy"
  value       = google_monitoring_alert_policy.high_retry_tasks.id
}

output "alert_policy_name" {
  description = "Resource name of the alert policy (projects/.../alertPolicies/...)"
  value       = google_monitoring_alert_policy.high_retry_tasks.name
}
