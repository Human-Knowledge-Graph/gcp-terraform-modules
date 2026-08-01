# Cloud Tasks — High Retry Tasks Alert Policy

Creates a `google_monitoring_alert_policy` that fires when the paired [`log_based_metrics/high_retry_tasks`](../../log_based_metrics/high_retry_tasks) metric receives data — i.e. when a task's dispatch attempts reach or exceed the threshold configured on that metric.

This module does **not** create the log-based metric or the notification channels. It only creates the alert policy, wired to a metric and channels you pass in. This keeps the three concerns (metric, notification channels, alert policy) independently composable.

## How it works

- **`metric_name`** must be the full `metric.type` path — the `metric_name` output of the `log_based_metrics/high_retry_tasks` module (`logging.googleapis.com/user/<name>`), not the bare metric name. Terraform does not validate that this string points at a real metric; a typo will `apply` successfully and simply never trigger the alert.
- **`notification_grouping = "per_task"`** (default) tracks each `task` label value as its own incident, so `task_id=42` retrying doesn't suppress a notification for `task_id=99`. `auto_close` (default 24h) keeps that same incident open across brief retry gaps so a single misbehaving task doesn't renotify repeatedly within that window.
- **`notification_grouping = "per_queue"`** collapses all tasks on the queue into a single time series/incident. Since there's only one incident either way, `notification_rate_limit` (300s) is added in this mode to smooth out rapid open/close flapping — this would be unsafe in `per_task` mode, where it could suppress a genuinely different task's alert.
- **`documentation`** renders the queue, project, and threshold via normal Terraform interpolation (`${var.queue_id}`), and the per-incident metric labels (task, target, status) via GCP's own notification-time template syntax (`$${metric.label.task}`, escaped with a double `$` so Terraform doesn't try to resolve it itself).

## Usage

Reference this module using a Git commit hash for version control:

```hcl
module "high_retry_tasks_metric" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/observability/cloudtask/log_based_metrics/high_retry_tasks?ref=COMMIT"

  project_id               = var.project_id
  queue_id                 = "my-task-queue"
  dispatch_count_threshold = 100
}

module "high_retry_tasks_alert" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/observability/cloudtask/alerting/high_retry_tasks?ref=COMMIT"

  project_id                = var.project_id
  queue_id                  = "my-task-queue"
  metric_name               = module.high_retry_tasks_metric.metric_name
  dispatch_count_threshold  = 100
  notification_channels     = [google_monitoring_notification_channel.email.name]
  notification_grouping     = "per_task"
}
```

### Per-queue grouping

```hcl
module "high_retry_tasks_alert" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/observability/cloudtask/alerting/high_retry_tasks?ref=COMMIT"

  project_id             = var.project_id
  queue_id               = "critical-queue"
  metric_name            = module.high_retry_tasks_metric.metric_name
  notification_channels  = [google_monitoring_notification_channel.pagerduty.name]
  notification_grouping  = "per_queue"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.7 |
| google | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 4.0 |

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_metric_name"></a> [metric_name](#input_metric_name) | Full metric type path of the high-retry-tasks log-based metric, e.g. the metric_name output of the log_based_metrics/high_retry_tasks module (logging.googleapis.com/user/<name>) | `string` | n/a | yes |
| <a name="input_notification_channels"></a> [notification_channels](#input_notification_channels) | List of notification channel resource names to notify (e.g. [google_monitoring_notification_channel.email.name]). Not created by this module — pass channels managed elsewhere. | `list(string)` | n/a | yes |
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID where the alert policy will be created | `string` | n/a | yes |
| <a name="input_queue_id"></a> [queue_id](#input_queue_id) | Cloud Tasks queue ID this alert monitors. Used for the display name and notification content only — the paired log-based metric is already scoped to this queue via its own filter. | `string` | n/a | yes |
| <a name="input_auto_close"></a> [auto_close](#input_auto_close) | Duration after which an open incident auto-closes if no new violating data arrives. In per_task mode this is what prevents renotifying for the same task while it keeps retrying with gaps (e.g. "86400s" for once per 24h). | `string` | `"86400s"` | no |
| <a name="input_dispatch_count_threshold"></a> [dispatch_count_threshold](#input_dispatch_count_threshold) | Retry threshold configured on the paired log-based metric. Used for the display name and documentation text only — must match the dispatch_count_threshold passed to the log_based_metrics/high_retry_tasks module. | `number` | `100` | no |
| <a name="input_notification_grouping"></a> [notification_grouping](#input_notification_grouping) | Whether incidents are tracked per individual task_id ("per_task", one incident and notification per retrying task) or aggregated across the whole queue ("per_queue", one incident for the queue as a whole) | `string` | `"per_task"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alert_policy_id"></a> [alert_policy_id](#output_alert_policy_id) | Fully qualified identifier of the alert policy |
| <a name="output_alert_policy_name"></a> [alert_policy_name](#output_alert_policy_name) | Resource name of the alert policy (projects/.../alertPolicies/...) |
<!-- END_TF_DOCS -->

## IAM Permissions Required

The account running Terraform needs:

- `roles/monitoring.alertPolicyEditor` — to create and manage alert policies

## Development

This module lives under a nested path (`modules/observability/...`) so the root Makefile targets that use a `modules/*/` glob (`make docs`, `make validate`) will not reach it automatically. Run these commands from the module directory instead:

```bash
cd modules/observability/cloudtask/alerting/high_retry_tasks

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

- **Loose coupling by design:** this module takes `metric_name` and `notification_channels` as plain strings/lists rather than instantiating the metric or channel modules itself, so callers can mix and match (e.g. one metric feeding two alert policies with different grouping, or channels shared across many alert policies).
- **`dispatch_count_threshold` is display-only here:** it doesn't affect alerting behavior in this module — the paired log-based metric already only counts entries at or above its own configured threshold. Keep this value in sync with the value passed to `log_based_metrics/high_retry_tasks` so the display name and documentation text stay accurate.
- **`per_task` vs `per_queue` is a one-way choice per alert policy instance:** switching `notification_grouping` changes `group_by_fields` on an existing policy, which Cloud Monitoring treats as a materially different condition — expect Terraform to show an in-place update, and any currently open incidents to close under the old grouping.
