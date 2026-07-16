locals {
  # dispatchCount is stored as a string in Cloud Tasks logs so numeric operators
  # do lexicographic comparison ("3" > "100" is true). We generate a regex that
  # precisely matches integers >= threshold using the standard digit-position algorithm:
  #
  # For each position i, fix digits 0..i-1 to the threshold value exactly, require
  # digit i to be strictly greater than threshold[i], then allow any digit afterward.
  # Combine all such alternatives with the longer-digit part and the exact threshold.
  #
  # Example — threshold 150 produces:
  #   ^([1-9][0-9]{3,}|[2-9][0-9]{2}|1[6-9][0-9]|15[1-9]|150)$

  threshold_str   = tostring(var.dispatch_count_threshold)
  threshold_chars = split("", local.threshold_str)
  threshold_len   = length(local.threshold_chars)

  # Integers with strictly more digits than the threshold are always greater.
  longer_part = "[1-9][0-9]{${local.threshold_len},}"

  # One alternative per digit position. Returns "" when threshold digit is 9
  # (no digit can exceed it), which compact() removes from the final list.
  same_length_parts = [
    for i in range(local.threshold_len) :
    tonumber(local.threshold_chars[i]) < 9 ? join("", concat(
      [for j in range(i) : local.threshold_chars[j]],
      ["[${tonumber(local.threshold_chars[i]) + 1}-9]"],
      i < local.threshold_len - 1 ? ["[0-9]{${local.threshold_len - i - 1}}"] : []
    )) : ""
  ]

  dispatch_count_regex = "^(${join("|", concat(
    [local.longer_part],
    compact(local.same_length_parts),
    [local.threshold_str]
  ))})$"
}

resource "google_logging_metric" "high_retry_tasks" {
  project     = var.project_id
  name        = var.metric_name
  description = "Counts Cloud Tasks attempt response log entries where dispatchCount >= threshold, labeled by task, target, and status"

  filter = <<-EOT
    resource.type="cloud_tasks_queue"
    resource.labels.queue_id="${var.queue_id}"
    jsonPayload.attemptResponseLog.dispatchCount =~ "${local.dispatch_count_regex}"
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"

    labels {
      key         = "task"
      value_type  = "STRING"
      description = "Cloud Tasks task identifier"
    }

    labels {
      key         = "target_address"
      value_type  = "STRING"
      description = "Target address the task is dispatched to"
    }

    labels {
      key         = "target_type"
      value_type  = "STRING"
      description = "Target type (e.g. HTTP)"
    }

    labels {
      key         = "status"
      value_type  = "STRING"
      description = "Attempt response status"
    }

    labels {
      key         = "max_attempts"
      value_type  = "STRING"
      description = "Maximum attempts configured on the queue"
    }
  }

  label_extractors = {
    "task"           = "EXTRACT(jsonPayload.task)"
    "target_address" = "EXTRACT(jsonPayload.attemptResponseLog.targetAddress)"
    "target_type"    = "EXTRACT(jsonPayload.attemptResponseLog.targetType)"
    "status"         = "EXTRACT(jsonPayload.attemptResponseLog.status)"
    "max_attempts"   = "EXTRACT(jsonPayload.attemptResponseLog.maxAttempts)"
  }
}
