output "enabled_services" {
  description = "List of enabled Google API services"
  value       = [for service in google_project_service.enabled_google_api_services : service.service]
}

output "services" {
  description = "Map of enabled Google API services with their full resource details"
  value       = google_project_service.enabled_google_api_services
}
