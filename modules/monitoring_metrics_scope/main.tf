resource "google_monitoring_monitored_project" "this" {
  for_each = var.monitored_project_ids

  metrics_scope = "locations/global/metricsScopes/${var.metrics_scope_project_id}"
  name          = "locations/global/metricsScopes/${var.metrics_scope_project_id}/projects/${each.value}"
}
