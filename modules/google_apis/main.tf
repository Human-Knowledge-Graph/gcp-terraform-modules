
# Enable multiple APIs
resource "google_project_service" "enabled_google_api_services" {
  for_each = toset(var.enabled_google_api_services)

  project = var.project_id
  service = each.key
}
