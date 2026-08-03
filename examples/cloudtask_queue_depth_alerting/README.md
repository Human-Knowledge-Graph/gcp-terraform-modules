# Example: Cloud Tasks Queue Depth Alerting (End-to-End)

Shows how to alert when a Cloud Tasks queue's depth stays elevated: a queue whose depth stays above a threshold for a sustained period sends an email.

This wires together two things:

1. **`google_monitoring_notification_channel`** (plain resource, not a module) — an email channel, created directly in this example so it's fully self-contained. In a real deployment you'd typically reuse a shared channel instead of creating one per alert.
2. **[`alerting/queue_depth`](../../modules/observability/cloudtask/alerting/queue_depth)** — the alert policy, pointed directly at the built-in `cloudtasks.googleapis.com/queue/depth` metric and wired to the email channel's `name`. Unlike the high-retry-tasks example, there's no log-based metric to create first — queue depth is already emitted by GCP for every queue.

```
                 depth_threshold, duration
                          │
                          ▼
  Cloud Tasks    ┌───────────────────┐    notification_channels    ┌──────────────────────────┐
  queue/depth ──▶│ alerting/          │◀────────────────────────────│ google_monitoring_        │
  (built-in)     │ queue_depth        │                              │ notification_channel      │──▶ email
                 └───────────────────┘                              └──────────────────────────┘
```

## Usage

This example uses **local module paths** (`../../modules/...`) so it can be planned/applied directly from within this repo. If you're consuming these modules from another repository, switch to the `git::...?ref=<commit>` source pattern documented in the module's own README.

```bash
cd examples/cloudtask_queue_depth_alerting

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

### Custom threshold and duration

```bash
terraform apply \
  -var="project_id=my-gcp-project" \
  -var="queue_id=my-task-queue" \
  -var="notification_email=oncall@example.com" \
  -var="depth_threshold=500" \
  -var="duration=3600s"
```

## What you get

- One incident (and one email) when the queue's depth stays above `depth_threshold` continuously for `duration` — defaults to depth > 200 sustained for 2 hours.
- An email whose body includes the project and queue via the alert module's `documentation` block.

## Prerequisites

- An existing Cloud Tasks queue (`queue_id`) — this example does not create the queue itself.
- IAM permissions on `project_id` for the identity running Terraform:
  - `roles/monitoring.alertPolicyEditor` — create the alert policy
  - `roles/monitoring.notificationChannelEditor` — create the email notification channel

## Cleanup

```bash
terraform destroy \
  -var="project_id=my-gcp-project" \
  -var="queue_id=my-task-queue" \
  -var="notification_email=oncall@example.com"
```
