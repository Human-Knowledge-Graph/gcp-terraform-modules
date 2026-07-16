output "metric_name" {
  description = "Full metric type path, used as the filter value in google_monitoring_alert_policy"
  value       = "logging.googleapis.com/user/${google_logging_metric.high_retry_tasks.name}"
}

output "metric_id" {
  description = "The bare metric name as stored in Cloud Logging"
  value       = google_logging_metric.high_retry_tasks.name
}

output "dispatch_count_regex" {
  description = "The generated regex used in the log filter to match dispatchCount >= dispatch_count_threshold"
  value       = local.dispatch_count_regex
}
