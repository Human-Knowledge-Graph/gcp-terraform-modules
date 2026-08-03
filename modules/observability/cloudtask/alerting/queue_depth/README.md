# Cloud Tasks — Queue Depth Alert Policy

Creates a `google_monitoring_alert_policy` that fires when a Cloud Tasks queue's depth stays above `depth_threshold` continuously for `duration`.

Unlike the [`high_retry_tasks`](../high_retry_tasks) alert, this module does **not** pair with a log-based metric. Queue depth is already a built-in Cloud Monitoring metric (`cloudtasks.googleapis.com/queue/depth`), so there's nothing to derive from logs — this module points an alert policy directly at it.

## How it works

- **`cloudtasks.googleapis.com/queue/depth`** is a GAUGE metric GCP samples roughly every 60s, representing the number of tasks in the queue that are pending or being retried (not counting tasks currently executing).
- **`aggregations`** buckets raw samples into `alignment_period`-sized windows (default 300s) and reduces each window with `ALIGN_MAX`, so a brief spike within a window isn't averaged away.
- **`duration`** (default `"7200s"`, 2 hours) is Cloud Monitoring's native support for "stay above threshold continuously" — the condition only fires once every aligned data point across the full duration has exceeded `depth_threshold`. This is the mechanism that encodes "queue depth above 200 for 2 hours," not a custom counting metric.
- **No per-task/per-queue grouping variable** (unlike `high_retry_tasks`): a queue has exactly one depth value, so there's only ever one time series and one incident per queue — nothing to group by.
- **`location`** is optional. Set it if `queue_id` values aren't unique across locations within the project; otherwise leave it `null` and the filter scopes on `project_id` + `queue_id` alone.

## Usage

Reference this module using a Git commit hash for version control:

```hcl
module "queue_depth_alert" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/observability/cloudtask/alerting/queue_depth?ref=COMMIT"

  project_id             = var.project_id
  queue_id               = "my-task-queue"
  notification_channels  = [google_monitoring_notification_channel.email.name]
}
```

### Custom threshold and duration

```hcl
module "queue_depth_alert" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/observability/cloudtask/alerting/queue_depth?ref=COMMIT"

  project_id             = var.project_id
  queue_id               = "critical-queue"
  location               = "us-central1"
  depth_threshold        = 500
  duration                = "3600s" # 1 hour
  notification_channels  = [google_monitoring_notification_channel.pagerduty.name]
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
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID where the Cloud Tasks queue resides and the alert policy will be created | `string` | n/a | yes |
| <a name="input_queue_id"></a> [queue_id](#input_queue_id) | Cloud Tasks queue ID this alert monitors | `string` | n/a | yes |
| <a name="input_notification_channels"></a> [notification_channels](#input_notification_channels) | List of notification channel resource names to notify (e.g. [google_monitoring_notification_channel.email.name]). Not created by this module — pass channels managed elsewhere. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input_location) | Location (region) of the Cloud Tasks queue, e.g. "us-central1". If set, scopes the alert filter to this location; leave null if queue_id is unique enough within the project. | `string` | `null` | no |
| <a name="input_depth_threshold"></a> [depth_threshold](#input_depth_threshold) | Queue depth (number of pending/retrying tasks) above which the alert fires | `number` | `200` | no |
| <a name="input_duration"></a> [duration](#input_duration) | How long queue depth must stay above depth_threshold, continuously, before the alert fires (Cloud Monitoring duration string, e.g. "7200s" for 2 hours) | `string` | `"7200s"` | no |
| <a name="input_alignment_period"></a> [alignment_period](#input_alignment_period) | Alignment period for sampling queue depth before comparing against depth_threshold (Cloud Monitoring duration string). Used with ALIGN_MAX, so the max depth observed within each period is what gets compared against the threshold. | `string` | `"300s"` | no |
| <a name="input_auto_close"></a> [auto_close](#input_auto_close) | Duration after which an open incident auto-closes if no new data arrives for the queue depth metric (e.g. "86400s" for 24h) | `string` | `"86400s"` | no |

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
cd modules/observability/cloudtask/alerting/queue_depth

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

- **No paired log-based metric:** unlike `high_retry_tasks`, queue depth doesn't need one — `cloudtasks.googleapis.com/queue/depth` is already emitted by GCP for every Cloud Tasks queue.
- **`ALIGN_MAX` over `ALIGN_MEAN`:** chosen deliberately so a spike that only lasts part of an `alignment_period` window still counts, rather than being smoothed out by averaging.
- **`duration` is the core mechanism:** the "sustained for N hours" requirement comes entirely from the alert policy's native `duration` field — no custom metric or counting logic is involved, unlike the regex-based threshold matching `high_retry_tasks` needs for its log-based metric.
- **One incident per queue:** since queue depth has no sub-dimension to group by (no task-level breakdown), there's no `notification_grouping` variable here.
- **Duration strings are validated:** `duration`, `alignment_period`, and `auto_close` must match Cloud Monitoring's `Duration` format — digits followed by `s` (e.g. `"7200s"`, `"0.5s"`). `terraform plan` rejects values like `"7200"` or `"2h"` instead of failing at `apply` against the GCP API.
