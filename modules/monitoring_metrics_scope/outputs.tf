output "monitored_projects" {
  description = "Monitored projects attached to the metrics scope"
  value       = keys(google_monitoring_monitored_project.this)
}
