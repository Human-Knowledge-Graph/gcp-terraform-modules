# Example: Cloud Tasks High Retry Alerting (End-to-End)

Shows how the pieces under `modules/observability/cloudtask/` compose into a working alerting setup: a task on a Cloud Tasks queue that retries too many times sends an email.

This wires together three things:

1. **[`log_based_metrics/high_retry_tasks`](../../modules/observability/cloudtask/log_based_metrics/high_retry_tasks)** — creates a log-based metric counting task attempts where `dispatchCount >= dispatch_count_threshold`.
2. **`google_monitoring_notification_channel`** (plain resource, not a module) — an email channel, created directly in this example so it's fully self-contained. In a real deployment you'd typically reuse a shared channel instead of creating one per alert.
3. **[`alerting/high_retry_tasks`](../../modules/observability/cloudtask/alerting/high_retry_tasks)** — the alert policy, wired to the metric's `metric_name` output and the email channel's `name`.

```
                 dispatch_count_threshold
                          │
                          ▼
  Cloud Tasks    ┌──────────────────────┐    metric_name    ┌───────────────────┐    notification_channels    ┌──────────────────────────┐
  queue logs ───▶│ log_based_metrics/   │───────────────────▶│ alerting/          │◀────────────────────────────│ google_monitoring_        │
                 │ high_retry_tasks      │                    │ high_retry_tasks   │                              │ notification_channel      │──▶ email
                 └──────────────────────┘                    └───────────────────┘                              └──────────────────────────┘
```

## Usage

This example uses **local module paths** (`../../modules/...`) so it can be planned/applied directly from within this repo. If you're consuming these modules from another repository, switch to the `git::...?ref=<commit>` source pattern documented in each module's own README.

```bash
cd examples/cloudtask_high_retry_alerting

terraform init

terraform plan \
  -var="project_id=my-gcp-project" \
  -var="queue_id=my-task-queue" \
  -var="notification_email=oncall@example.com"

terraform apply \
  -var="project_id=my-gcp-project" \
  -var="queue_id=my-task-queue" \
  -var="notification_email=oncall@example.com"
```

Or with a `terraform.tfvars`:

```hcl
project_id         = "my-gcp-project"
queue_id           = "my-task-queue"
notification_email = "oncall@example.com"
```

### Per-queue grouping instead of per-task

```bash
terraform apply \
  -var="project_id=my-gcp-project" \
  -var="queue_id=my-task-queue" \
  -var="notification_email=oncall@example.com" \
  -var="notification_grouping=per_queue"
```

## What you get

- One incident (and one email) per retrying `task_id`, by default — a different task crossing the threshold doesn't suppress notification for another. See the alert module's README for the full `per_task` vs `per_queue` explanation, and how `auto_close` prevents renotifying for the same task within 24h.
- An email whose body includes the specific task, target address, and status, via the alert module's `documentation` block.

## Prerequisites

- An existing Cloud Tasks queue (`queue_id`) generating `attemptResponseLog` entries — this example does not create the queue itself.
- IAM permissions on `project_id` for the identity running Terraform:
  - `roles/logging.admin` — create the log-based metric
  - `roles/monitoring.alertPolicyEditor` — create the alert policy
  - `roles/monitoring.notificationChannelEditor` — create the email notification channel

## Cleanup

```bash
terraform destroy \
  -var="project_id=my-gcp-project" \
  -var="queue_id=my-task-queue" \
  -var="notification_email=oncall@example.com"
```
