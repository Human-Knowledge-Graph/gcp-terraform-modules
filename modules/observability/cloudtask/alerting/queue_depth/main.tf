locals {
  display_name = "[Cloud Tasks] Project \"${var.project_id}\" queue \"${var.queue_id}\" - queue depth above ${var.depth_threshold} for ${var.duration}"

  location_filter = var.location != null ? " AND resource.labels.location=\"${var.location}\"" : ""

  filter = <<-EOT
    resource.type="cloud_tasks_queue"
    resource.labels.project_id="${var.project_id}"
    resource.labels.queue_id="${var.queue_id}"${local.location_filter}
    metric.type="cloudtasks.googleapis.com/queue/depth"
  EOT
}

resource "google_monitoring_alert_policy" "queue_depth" {
  project      = var.project_id
  display_name = local.display_name
  combiner     = "OR"

  conditions {
    display_name = "queue depth > ${var.depth_threshold} for ${var.duration}"

    condition_threshold {
      filter          = local.filter
      comparison      = "COMPARISON_GT"
      threshold_value = var.depth_threshold
      duration        = var.duration

      aggregations {
        alignment_period   = var.alignment_period
        per_series_aligner = "ALIGN_MAX"
      }
    }
  }

  alert_strategy {
    auto_close = var.auto_close
  }

  documentation {
    content = <<-EOT
      Project `${var.project_id}`, Cloud Tasks queue `${var.queue_id}` has had a queue depth above ${var.depth_threshold} continuously for ${var.duration}.

      Queue depth is normally 0. A sustained elevated depth usually means tasks are failing to dispatch or are being dispatched slower than they're being enqueued.

      Investigate in the Cloud Tasks console.
    EOT

    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
}
