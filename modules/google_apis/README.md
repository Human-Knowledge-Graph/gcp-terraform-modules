# Google APIs Module

This module enables multiple Google Cloud APIs for a GCP project.

## Features

- Enable multiple Google Cloud APIs in a single module call
- Uses `for_each` for efficient resource management
- Automatically manages API service enablement

## Usage

Reference this module using a Git commit hash for version control:

```hcl
module "google_apis" {
  # Pin to specific commit - check CHANGELOG.md for latest stable commits
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/google_apis?ref=6a077c4"

  project_id = "my-gcp-project"

  enabled_google_api_services = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}
```

> **Finding the right commit:** Check this module's [CHANGELOG.md](./CHANGELOG.md) for stable commit hashes, or use `git log modules/google_apis` to see recent changes.

### Basic Example - Enable Common APIs

```hcl
module "google_apis" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/google_apis?ref=6a077c4"

  project_id = "my-gcp-project"

  enabled_google_api_services = [
    "compute.googleapis.com",
    "storage-api.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}
```

### Enable GKE-Related APIs

```hcl
module "gke_apis" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/google_apis?ref=6a077c4"

  project_id = "my-gcp-project"

  enabled_google_api_services = [
    "container.googleapis.com",
    "compute.googleapis.com",
    "storage-api.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}
```

### Enable Serverless APIs

```hcl
module "serverless_apis" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/google_apis?ref=6a077c4"

  project_id = "my-gcp-project"

  enabled_google_api_services = [
    "run.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
}
```

### With Outputs

```hcl
module "google_apis" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/google_apis?ref=6a077c4"

  project_id = var.project_id

  enabled_google_api_services = [
    "compute.googleapis.com",
    "storage.googleapis.com"
  ]
}

output "enabled_apis" {
  description = "List of enabled APIs"
  value       = module.google_apis.enabled_services
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The unique ID of the project | `string` | n/a | yes |
| enabled_google_api_services | List of APIs to enable for the project | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| enabled_services | List of enabled Google API services |
| services | Map of enabled Google API services with their full resource details |

## Common Google Cloud APIs

Here are some commonly used Google Cloud API service names:

**Compute & Networking:**
- `compute.googleapis.com` - Compute Engine API
- `container.googleapis.com` - Google Kubernetes Engine API
- `servicenetworking.googleapis.com` - Service Networking API

**Storage:**
- `storage-api.googleapis.com` - Cloud Storage API
- `storage.googleapis.com` - Cloud Storage JSON API
- `file.googleapis.com` - Cloud Filestore API

**Databases:**
- `sqladmin.googleapis.com` - Cloud SQL Admin API
- `spanner.googleapis.com` - Cloud Spanner API
- `firestore.googleapis.com` - Cloud Firestore API

**Serverless:**
- `run.googleapis.com` - Cloud Run API
- `cloudfunctions.googleapis.com` - Cloud Functions API
- `appengine.googleapis.com` - App Engine Admin API

**CI/CD & DevOps:**
- `cloudbuild.googleapis.com` - Cloud Build API
- `artifactregistry.googleapis.com` - Artifact Registry API
- `containerregistry.googleapis.com` - Container Registry API

**Observability:**
- `logging.googleapis.com` - Cloud Logging API
- `monitoring.googleapis.com` - Cloud Monitoring API
- `cloudtrace.googleapis.com` - Cloud Trace API

**Management:**
- `cloudresourcemanager.googleapis.com` - Cloud Resource Manager API
- `serviceusage.googleapis.com` - Service Usage API
- `iam.googleapis.com` - Identity and Access Management API

**Security:**
- `secretmanager.googleapis.com` - Secret Manager API
- `cloudkms.googleapis.com` - Cloud Key Management Service API

For a complete list, see: [Google Cloud APIs Library](https://console.cloud.google.com/apis/library)

## IAM Permissions Required

The service account or user running Terraform must have the following permissions:

- `serviceusage.services.enable`
- `serviceusage.services.get`
- `serviceusage.services.list`

These are included in the following predefined roles:
- `roles/serviceusage.serviceUsageAdmin`
- `roles/editor`
- `roles/owner`

## Notes

- Enabling an API may take a few minutes to propagate
- Some APIs have dependencies on other APIs (e.g., GKE requires Compute Engine API)
- Disabling APIs is not automatic when removing from the list - use `disable_on_destroy = true` if needed
- API enablement is a project-level setting
- Some APIs may incur costs even when not actively used

## Related Resources

- [Google Cloud APIs Documentation](https://cloud.google.com/apis/docs/overview)
- [Service Usage API Documentation](https://cloud.google.com/service-usage/docs)
