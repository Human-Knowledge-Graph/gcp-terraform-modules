# Tests for the queue depth alert policy.
#
# mock_provider stubs the Google provider so no GCP credentials are needed —
# this runs safely in CI without any service account configuration.

mock_provider "google" {}

variables {
  project_id            = "fake-project"
  queue_id              = "fake-queue"
  notification_channels = ["projects/fake-project/notificationChannels/1"]
}

# ── defaults ──────────────────────────────────────────────────────────────────

run "defaults" {
  command = plan

  assert {
    condition     = google_monitoring_alert_policy.queue_depth.combiner == "OR"
    error_message = "combiner must default to OR"
  }

  assert {
    condition     = google_monitoring_alert_policy.queue_depth.conditions[0].condition_threshold[0].threshold_value == 200
    error_message = "depth_threshold must default to 200"
  }

  assert {
    condition     = google_monitoring_alert_policy.queue_depth.conditions[0].condition_threshold[0].duration == "7200s"
    error_message = "duration must default to 7200s (2 hours)"
  }

  assert {
    condition     = google_monitoring_alert_policy.queue_depth.conditions[0].condition_threshold[0].comparison == "COMPARISON_GT"
    error_message = "comparison must be COMPARISON_GT"
  }

  assert {
    condition     = google_monitoring_alert_policy.queue_depth.conditions[0].condition_threshold[0].aggregations[0].per_series_aligner == "ALIGN_MAX"
    error_message = "per_series_aligner must be ALIGN_MAX"
  }

  assert {
    condition     = google_monitoring_alert_policy.queue_depth.conditions[0].condition_threshold[0].aggregations[0].alignment_period == "300s"
    error_message = "alignment_period must default to 300s"
  }

  assert {
    condition     = google_monitoring_alert_policy.queue_depth.alert_strategy[0].auto_close == "86400s"
    error_message = "auto_close must default to 86400s"
  }

  assert {
    condition     = strcontains(google_monitoring_alert_policy.queue_depth.conditions[0].condition_threshold[0].filter, "cloudtasks.googleapis.com/queue/depth")
    error_message = "filter must target the queue depth metric"
  }

  assert {
    condition     = strcontains(google_monitoring_alert_policy.queue_depth.conditions[0].condition_threshold[0].filter, "fake-queue")
    error_message = "filter must scope to the queue_id"
  }

  assert {
    condition     = !strcontains(google_monitoring_alert_policy.queue_depth.conditions[0].condition_threshold[0].filter, "resource.labels.location")
    error_message = "filter must not include a location clause when location is not set"
  }

  assert {
    condition     = strcontains(google_monitoring_alert_policy.queue_depth.display_name, "fake-project")
    error_message = "display_name must include the project id"
  }

  assert {
    condition     = strcontains(google_monitoring_alert_policy.queue_depth.display_name, "fake-queue")
    error_message = "display_name must include the queue id"
  }

  assert {
    condition     = strcontains(google_monitoring_alert_policy.queue_depth.documentation[0].content, "fake-project")
    error_message = "documentation content must include the project id"
  }
}

# ── location filter ──────────────────────────────────────────────────────────

run "location_adds_filter_clause" {
  command = plan

  variables { location = "us-central1" }

  assert {
    condition     = strcontains(google_monitoring_alert_policy.queue_depth.conditions[0].condition_threshold[0].filter, "resource.labels.location=\"us-central1\"")
    error_message = "filter must include the location clause when location is set"
  }
}

# ── custom threshold and duration ────────────────────────────────────────────

run "custom_threshold_and_duration" {
  command = plan

  variables {
    depth_threshold = 500
    duration        = "3600s"
  }

  assert {
    condition     = google_monitoring_alert_policy.queue_depth.conditions[0].condition_threshold[0].threshold_value == 500
    error_message = "threshold_value must reflect depth_threshold"
  }

  assert {
    condition     = google_monitoring_alert_policy.queue_depth.conditions[0].condition_threshold[0].duration == "3600s"
    error_message = "duration must reflect the custom duration"
  }

  assert {
    condition     = strcontains(google_monitoring_alert_policy.queue_depth.display_name, "500")
    error_message = "display_name must reflect the custom threshold"
  }
}

# ── duration format validation ───────────────────────────────────────────────

run "invalid_duration_rejected" {
  command = plan

  variables { duration = "7200" }

  expect_failures = [var.duration]
}

run "invalid_alignment_period_rejected" {
  command = plan

  variables { alignment_period = "5m" }

  expect_failures = [var.alignment_period]
}

run "invalid_auto_close_rejected" {
  command = plan

  variables { auto_close = "1d" }

  expect_failures = [var.auto_close]
}
