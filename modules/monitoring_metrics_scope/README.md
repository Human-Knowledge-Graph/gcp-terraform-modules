# Monitoring Metrics Scope Module

This module configures Cloud Monitoring metrics scopes in Google Cloud Platform. It allows you to add monitored projects to a central metrics scope (host project), enabling cross-project metrics visibility.

## Features

- Add multiple projects to a metrics scope
- Centralized monitoring across multiple GCP projects
- Ideal for multi-project environments and organizations

## Usage

Reference this module using a Git commit hash for version control:

```hcl
module "monitoring_metrics_scope" {
  # Pin to specific commit - check CHANGELOG.md for latest stable commits
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/monitoring_metrics_scope?ref=COMMIT_HASH"

  metrics_scope_project_id = "my-monitoring-project"
  monitored_project_ids    = ["project-a", "project-b", "project-c"]
}
```

> **Finding the right commit:** Check this module's [CHANGELOG.md](./CHANGELOG.md) for stable commit hashes, or use `git log modules/monitoring_metrics_scope` to see recent changes.

### Basic Example

```hcl
module "monitoring_metrics_scope" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/monitoring_metrics_scope?ref=COMMIT_HASH"

  metrics_scope_project_id = "central-monitoring-project"
  monitored_project_ids    = ["dev-project", "staging-project", "prod-project"]
}
```

## IAM Permissions Required

The service account or user running Terraform must have the following permissions:

- `monitoring.metricsScopes.link`

These are included in the following predefined roles:
- `roles/monitoring.admin`
- `roles/editor`
- `roles/owner`

## Notes

- The metrics scope project (host project) must have Cloud Monitoring API enabled
- All monitored projects must belong to the same organization or have appropriate cross-project permissions
- Removing a project from `monitored_project_ids` will remove it from the metrics scope

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metrics_scope_project_id"></a> [metrics_scope_project_id](#input_metrics_scope_project_id) | Project ID of the central Cloud Monitoring metrics scope (host project) | `string` | n/a | yes |
| <a name="input_monitored_project_ids"></a> [monitored_project_ids](#input_monitored_project_ids) | Set of project IDs whose metrics should be visible in the metrics scope | `set(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_monitored_projects"></a> [monitored_projects](#output_monitored_projects) | Monitored projects attached to the metrics scope |
<!-- END_TF_DOCS -->
