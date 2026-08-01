# Tests for the alert policy's grouping-dependent behavior.
#
# mock_provider stubs the Google provider so no GCP credentials are needed —
# this runs safely in CI without any service account configuration.

mock_provider "google" {}

variables {
  project_id            = "fake-project"
  queue_id              = "fake-queue"
  metric_name           = "logging.googleapis.com/user/cloudtasks_high_retry_count"
  notification_channels = ["projects/fake-project/notificationChannels/1"]
}

# ── per_task grouping (default) ──────────────────────────────────────────────

run "per_task_groups_by_task_label" {
  command = plan

  variables { notification_grouping = "per_task" }

  assert {
    condition     = google_monitoring_alert_policy.high_retry_tasks.conditions[0].condition_threshold[0].aggregations[0].group_by_fields[0] == "metric.label.task"
    error_message = "per_task grouping must group by metric.label.task"
  }

  assert {
    condition     = length(google_monitoring_alert_policy.high_retry_tasks.alert_strategy[0].notification_rate_limit) == 0
    error_message = "per_task grouping must not set notification_rate_limit"
  }
}

# ── per_queue grouping ────────────────────────────────────────────────────────

run "per_queue_has_no_group_by_fields" {
  command = plan

  variables { notification_grouping = "per_queue" }

  assert {
    condition     = length(google_monitoring_alert_policy.high_retry_tasks.conditions[0].condition_threshold[0].aggregations[0].group_by_fields) == 0
    error_message = "per_queue grouping must not set group_by_fields"
  }

  assert {
    condition     = length(google_monitoring_alert_policy.high_retry_tasks.alert_strategy[0].notification_rate_limit) == 1
    error_message = "per_queue grouping must set notification_rate_limit"
  }

  assert {
    condition     = google_monitoring_alert_policy.high_retry_tasks.alert_strategy[0].notification_rate_limit[0].period == "300s"
    error_message = "per_queue notification_rate_limit period must be 300s"
  }
}

# ── validation ────────────────────────────────────────────────────────────────

run "invalid_grouping_rejected" {
  command = plan

  variables { notification_grouping = "per_project" }

  expect_failures = [var.notification_grouping]
}

# ── defaults and display content ─────────────────────────────────────────────

run "defaults_and_display_name" {
  command = plan

  assert {
    condition     = google_monitoring_alert_policy.high_retry_tasks.combiner == "OR"
    error_message = "combiner must default to OR"
  }

  assert {
    condition     = google_monitoring_alert_policy.high_retry_tasks.alert_strategy[0].auto_close == "86400s"
    error_message = "auto_close must default to 86400s"
  }

  assert {
    condition     = strcontains(google_monitoring_alert_policy.high_retry_tasks.display_name, "fake-project")
    error_message = "display_name must include the project id"
  }

  assert {
    condition     = strcontains(google_monitoring_alert_policy.high_retry_tasks.display_name, "fake-queue")
    error_message = "display_name must include the queue id"
  }

  assert {
    condition     = strcontains(google_monitoring_alert_policy.high_retry_tasks.documentation[0].content, "fake-project")
    error_message = "documentation content must include the project id"
  }
}
