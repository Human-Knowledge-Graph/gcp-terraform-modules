locals {
  display_name = "[Cloud Tasks] Project \"${var.project_id}\" queue \"${var.queue_id}\" - task exceeded ${var.dispatch_count_threshold} retries"
}

resource "google_monitoring_alert_policy" "high_retry_tasks" {
  project      = var.project_id
  display_name = local.display_name
  combiner     = "OR"

  conditions {
    display_name = "dispatchCount >= ${var.dispatch_count_threshold}"

    condition_threshold {
      filter          = "resource.type=\"global\" AND metric.type=\"${var.metric_name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_COUNT"
        group_by_fields    = var.notification_grouping == "per_task" ? ["metric.label.task"] : []
      }
    }
  }

  alert_strategy {
    auto_close = var.auto_close

    # Safe only in per_queue mode: with one incident per queue there's no risk
    # of one task's notification suppressing a different task's notification.
    dynamic "notification_rate_limit" {
      for_each = var.notification_grouping == "per_queue" ? [1] : []

      content {
        period = "300s"
      }
    }
  }

  documentation {
    content = <<-EOT
      Project `${var.project_id}`, Cloud Tasks queue `${var.queue_id}` has one or more tasks exceeding ${var.dispatch_count_threshold} dispatch retries.

      Task: $${metric.label.task}
      Target address: $${metric.label.target_address}
      Target type: $${metric.label.target_type}
      Status: $${metric.label.status}
      Max attempts configured: $${metric.label.max_attempts}

      Investigate in the Cloud Tasks console.
    EOT

    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
}
