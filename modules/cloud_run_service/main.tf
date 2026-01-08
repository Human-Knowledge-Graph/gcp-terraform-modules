resource "google_cloud_run_service" "default" {
  name     = var.cloud_run_service_name
  location = var.region


  template {
    spec {
      containers {
        image = var.image

        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }
      }


    }
  }
}


# IAM Binding to allow all users to invoke the Cloud Run service
resource "google_cloud_run_service_iam_binding" "cloud_run_service_invokers" {
  service  = google_cloud_run_service.default.name
  location = var.region
  role     = "roles/run.invoker"

  members = var.allowed_invoker_members
}
