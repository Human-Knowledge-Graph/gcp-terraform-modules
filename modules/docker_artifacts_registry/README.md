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
| <a name="input_artifacts_repository_id"></a> [artifacts_repository_id](#input_artifacts_repository_id) | Name of the artifacts repository | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input_location) | Location to store the artifacts | `string` | n/a | yes |
| <a name="input_project_id"></a> [project_id](#input_project_id) | Google project id | `string` | n/a | yes |
| <a name="input_cleanup_policy_dry_run"></a> [cleanup_policy_dry_run](#input_cleanup_policy_dry_run) | If true, cleanup policies will only log what would be deleted without actually deleting | `bool` | `false` | no |
| <a name="input_count_of_versions_to_keep"></a> [count_of_versions_to_keep](#input_count_of_versions_to_keep) | Determines number of version to keep | `number` | `1` | no |
| <a name="input_delete_older_than_days"></a> [delete_older_than_days](#input_delete_older_than_days) | Number of days after which tagged artifacts should be deleted | `number` | `30` | no |
| <a name="input_description"></a> [description](#input_description) | Description of the artifacts registry repository | `string` | `""` | no |
| <a name="input_tags_to_delete_after_a_month"></a> [tags_to_delete_after_a_month](#input_tags_to_delete_after_a_month) | Tags of artifacts to delete after specified days. Empty list means all tags (except those in tags_to_keep_forever) | `list(string)` | `[]` | no |
| <a name="input_tags_to_keep_forever"></a> [tags_to_keep_forever](#input_tags_to_keep_forever) | Tags of artifacts to keep until manually deleted | `list(string)` | <pre>[<br/>  "release",<br/>  "latest"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_id"></a> [repository_id](#output_repository_id) | Id of the repository |
| <a name="output_repository_name"></a> [repository_name](#output_repository_name) | Name of the repository |
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
