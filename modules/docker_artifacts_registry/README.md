# Docker Artifacts Registry Module

This module creates a Google Artifact Registry repository for Docker images with configurable cleanup policies.

## Usage

```hcl
module "docker_registry" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/docker_artifacts_registry?ref=fea94fb"

  project_id               = "my-gcp-project"
  location                 = "us-central1"
  artifacts_repository_id  = "my-docker-repo"
  description              = "Docker repository for my project"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| google | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 4.0 |

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | Google project id | `string` | n/a | yes |
| location | Location to store the artifacts | `string` | n/a | yes |
| artifacts_repository_id | Name of the artifacts repository | `string` | n/a | yes |
| description | Description of the artifacts registry repository | `string` | `""` | no |
| cleanup_policy_dry_run | If true, cleanup policies will only log what would be deleted without actually deleting | `bool` | `false` | no |
| delete_older_than_days | Number of days after which tagged artifacts should be deleted | `number` | `30` | no |
| tags_to_delete_after_a_month | Tags of artifacts that should be deleted after the specified days | `list(string)` | `["alpha", "beta"]` | no |
| tags_to_keep_forever | Tags of artifacts to keep until manually deleted | `list(string)` | `["release"]` | no |
| count_of_versions_to_keep | Determines number of version to keep | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_id | Id of the repository |
| repository_name | Name of the repository |
<!-- END_TF_DOCS -->

## IAM Permissions Required

The service account or user running Terraform must have the following permissions:

- `artifactregistry.repositories.create`
- `artifactregistry.repositories.get`
- `artifactregistry.repositories.update`
- `artifactregistry.repositories.delete`

These are included in the following predefined roles:
- `roles/artifactregistry.admin`
- `roles/editor`
- `roles/owner`
