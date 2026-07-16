# Cloud Tasks — High Retry Tasks Log-Based Metric

Creates a Cloud Logging log-based metric that counts Cloud Tasks attempts where `dispatchCount >= dispatch_count_threshold`. Each log entry that matches increments the metric, so an alert policy built on top of it stays active for as long as the task keeps retrying above the threshold.

## How it works

Cloud Tasks writes an `attemptResponseLog` entry to Cloud Logging each time a task attempt receives a response. Each entry contains `dispatchCount` — how many times that task has been dispatched so far — stored as a **string**.

Because string comparison makes `"3" > "100"` true, a numeric threshold cannot be applied directly. This module generates a precise regex using the digit-position algorithm so that `dispatch_count_threshold = 150` matches exactly 150 and above, not 100 and above.

## Usage

Reference this module using a Git commit hash for version control:

```hcl
module "high_retry_tasks_metric" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/observability/cloudtask/log_based_metrics/high_retry_tasks?ref=COMMIT"

  project_id = "my-gcp-project"
  queue_id   = "my-task-queue"
}
```

### Wire the output into an alert policy

```hcl
module "high_retry_tasks_metric" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/observability/cloudtask/log_based_metrics/high_retry_tasks?ref=COMMIT"

  project_id               = var.project_id
  queue_id                 = "my-task-queue"
  dispatch_count_threshold = 100
}

resource "google_monitoring_alert_policy" "high_retry_tasks" {
  project      = var.project_id
  display_name = "[Cloud Tasks] Task exceeded 100 retries"
  combiner     = "OR"

  conditions {
    display_name = "dispatchCount >= 100"
    condition_threshold {
      filter          = "resource.type=\"global\" AND metric.type=\"${module.high_retry_tasks_metric.metric_name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_COUNT"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]
}
```

### Custom threshold

```hcl
module "high_retry_tasks_metric" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/observability/cloudtask/log_based_metrics/high_retry_tasks?ref=COMMIT"

  project_id               = var.project_id
  queue_id                 = "critical-queue"
  metric_name              = "cloudtasks_critical_queue_high_retry"
  dispatch_count_threshold = 50
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| google | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 4.0 |

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID where the Cloud Tasks queue and log-based metric reside | `string` | n/a | yes |
| <a name="input_queue_id"></a> [queue\_id](#input\_queue\_id) | Cloud Tasks queue ID to monitor | `string` | n/a | yes |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | Name of the log-based metric (must be unique within the project) | `string` | `"cloudtasks_high_retry_count"` | no |
| <a name="input_dispatch_count_threshold"></a> [dispatch\_count\_threshold](#input\_dispatch\_count\_threshold) | Minimum number of dispatches a task must have reached to be counted by this metric. Tasks at or above this value are included. | `number` | `100` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_metric_name"></a> [metric\_name](#output\_metric\_name) | Full metric type path, used as the filter value in google\_monitoring\_alert\_policy |
| <a name="output_metric_id"></a> [metric\_id](#output\_metric\_id) | The bare metric name as stored in Cloud Logging |
| <a name="output_dispatch_count_regex"></a> [dispatch\_count\_regex](#output\_dispatch\_count\_regex) | The generated regex used in the log filter to match dispatchCount >= dispatch\_count\_threshold |
<!-- END_TF_DOCS -->

## Labels extracted per metric data point

| Label | Source field |
|---|---|
| `task` | `jsonPayload.task` |
| `target_address` | `jsonPayload.attemptResponseLog.targetAddress` |
| `target_type` | `jsonPayload.attemptResponseLog.targetType` |
| `status` | `jsonPayload.attemptResponseLog.status` |
| `max_attempts` | `jsonPayload.attemptResponseLog.maxAttempts` |

## IAM Permissions Required

The account running Terraform needs:

- `roles/logging.admin` — to create log-based metrics

## Development

This module lives under a nested path (`modules/observability/...`) so the root Makefile targets that use a `modules/*/` glob (`make docs`, `make validate`) will not reach it automatically. Run these commands from the module directory instead:

```bash
cd modules/observability/cloudtask/log_based_metrics/high_retry_tasks

# Validate configuration syntax
terraform init -backend=false && terraform validate

# Format files
terraform fmt

# Regenerate README inputs/outputs table
terraform-docs markdown table --output-file README.md --output-mode inject .

# Run unit tests (no GCP credentials required — uses plan mode)
terraform test
```

Or run the root commands for formatting and docs across all modules:

```bash
# From repo root
make fmt          # format all .tf files recursively
make fmt-check    # check formatting (CI)
make docs         # regenerate docs for top-level modules only
```

## Notes

- **Threshold precision:** The regex is generated to match exactly `>= dispatch_count_threshold` for any integer value, including non-round numbers like 150 or 250.
- **dispatchCount is a string:** Cloud Tasks stores this field as a quoted string in `jsonPayload`. Numeric operators in Cloud Logging use lexicographic ordering for string fields, which is why this module uses a generated regex instead.
- **Alert stays active:** Because the metric fires on every retry at or above the threshold, a `google_monitoring_alert_policy` built on it remains open as long as the task keeps retrying — it does not fire only once.
- **Metric uniqueness:** `metric_name` must be unique within the project. If you monitor multiple queues, set a distinct name per module instance.
