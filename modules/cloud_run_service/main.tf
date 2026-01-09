resource "google_cloud_run_service" "default" {
  name     = var.cloud_run_service_name
  location = var.region

  template {
    metadata {
      annotations = merge(
        {
          "autoscaling.knative.dev/minScale" = var.min_instances
          "autoscaling.knative.dev/maxScale" = var.max_instances
        },
        var.cloudsql_instances != null ? {
          "run.googleapis.com/cloudsql-instances" = var.cloudsql_instances
        } : {},
        var.client_name != null ? {
          "run.googleapis.com/client-name" = var.client_name
        } : {},
        var.client_version != null ? {
          "run.googleapis.com/client-version" = var.client_version
        } : {}
      )
    }

    spec {
      service_account_name  = var.service_account_email
      container_concurrency = var.container_concurrency
      timeout_seconds       = var.timeout_seconds

      containers {
        image = var.image

        ports {
          container_port = var.container_port
        }

        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }

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

  traffic {
    percent         = 100
    latest_revision = true
    tag             = var.revision_tag
  }

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = var.ingress
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
