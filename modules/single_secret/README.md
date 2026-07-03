# Single Secret Module

This module creates a Google Secret Manager secret with automatic replication and grants IAM access permissions to specified service accounts.

## Features

- Creates a Secret Manager secret with automatic replication
- Grants IAM access permissions to service accounts
- Uses `secretAccessor` role for read-only access to secret values

## Usage

Reference this module using a Git commit hash for version control:

```hcl
module "single_secret" {
  # Pin to specific commit - check CHANGELOG.md for latest stable commits
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/single_secret?ref=0b74c7b"

  secret_id = "my-application-secret"

  service_account_with_access_permissions = [
    "serviceAccount:my-app@my-project.iam.gserviceaccount.com",
    "serviceAccount:backend@my-project.iam.gserviceaccount.com"
  ]
}
```

> **Finding the right commit:** Check this module's [CHANGELOG.md](./CHANGELOG.md) for stable commit hashes, or use `git log modules/single_secret` to see recent changes.

### Basic Example - Create Secret with Access

```hcl
module "api_key_secret" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/single_secret?ref=0b74c7b"

  secret_id = "api-key"

  service_account_with_access_permissions = [
    "serviceAccount:app-service@my-project.iam.gserviceaccount.com"
  ]
}

# Access the secret in other resources
resource "google_cloud_run_service" "app" {
  name     = "my-app"
  location = "us-central1"

  template {
    spec {
      service_account_name = "app-service@my-project.iam.gserviceaccount.com"

      containers {
        image = "gcr.io/my-project/my-app"

        env {
          name = "API_KEY"
          value_from {
            secret_key_ref {
              name = module.api_key_secret.secret_name
              key  = "latest"
            }
          }
        }
      }
    }
  }
}
```

### Multiple Service Accounts

```hcl
module "database_password" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/single_secret?ref=0b74c7b"

  secret_id = "database-password"

  service_account_with_access_permissions = [
    "serviceAccount:backend-api@my-project.iam.gserviceaccount.com",
    "serviceAccount:worker@my-project.iam.gserviceaccount.com",
    "serviceAccount:admin-tool@my-project.iam.gserviceaccount.com"
  ]
}
```

### Without Access Permissions

```hcl
module "secret_only" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/single_secret?ref=0b74c7b"

  secret_id = "my-secret"

  # No service accounts specified - permissions managed separately
  service_account_with_access_permissions = []
}
```

### With Outputs

```hcl
module "app_secret" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/single_secret?ref=0b74c7b"

  secret_id = "app-config"

  service_account_with_access_permissions = [
    "serviceAccount:app@my-project.iam.gserviceaccount.com"
  ]
}

output "secret_full_id" {
  description = "Full resource ID of the secret"
  value       = module.app_secret.secret_id
}

output "secret_name" {
  description = "Name of the secret"
  value       = module.app_secret.secret_name
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
| secret_id | The secret ID (name) for the secret | `string` | n/a | yes |
| service_account_with_access_permissions | List of service accounts with permission to access the secret | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| secret_id | The full resource ID of the secret (format: projects/{{project}}/secrets/{{secret_id}}) |
| secret_name | The name of the secret |

## IAM Permissions Required

The service account or user running Terraform must have the following permissions:

- `secretmanager.secrets.create`
- `secretmanager.secrets.get`
- `secretmanager.secrets.delete`
- `secretmanager.secrets.setIamPolicy`
- `secretmanager.secrets.getIamPolicy`

These are included in the following predefined roles:
- `roles/secretmanager.admin`
- `roles/editor`
- `roles/owner`

## Notes

- **Secret Values:** This module only creates the secret structure. You must add secret versions separately using `google_secret_manager_secret_version` or manually in the console
- **Replication:** Uses automatic replication across all available regions. For specific regions, you'll need to modify the replication block
- **IAM Binding:** Uses `google_secret_manager_secret_iam_binding` which is authoritative for the role. This will remove any other bindings for the `secretAccessor` role
- **Service Account Format:** Use the full service account format: `serviceAccount:name@project.iam.gserviceaccount.com`
- **Secret Manager API:** Ensure the Secret Manager API (`secretmanager.googleapis.com`) is enabled in your project

## Adding Secret Versions

After creating the secret with this module, add versions:

```hcl
# Create the secret structure
module "my_secret" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/single_secret?ref=0b74c7b"

  secret_id = "my-secret"

  service_account_with_access_permissions = [
    "serviceAccount:app@my-project.iam.gserviceaccount.com"
  ]
}

# Add a secret version with the actual secret data
resource "google_secret_manager_secret_version" "my_secret_version" {
  secret = module.my_secret.secret_id

  secret_data = var.secret_value  # Sensitive value from variable
}
```

## Security Best Practices

- Never commit secret values to version control
- Use Terraform variables marked as `sensitive = true` for secret data
- Enable audit logging for secret access
- Rotate secrets regularly
- Use least privilege - only grant access to service accounts that need it
- Consider using automatic replication only for non-sensitive data; use user-managed replication for sensitive secrets

## Related Resources

- [Google Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)
- [Secret Manager Best Practices](https://cloud.google.com/secret-manager/docs/best-practices)
- [IAM Roles for Secret Manager](https://cloud.google.com/secret-manager/docs/access-control)

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_secret_id"></a> [secret_id](#input_secret_id) | n/a | `string` | n/a | yes |
| <a name="input_service_account_with_access_permissions"></a> [service_account_with_access_permissions](#input_service_account_with_access_permissions) | Determines list of service accounts with permission to access the secret | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_secret_id"></a> [secret_id](#output_secret_id) | n/a |
| <a name="output_secret_name"></a> [secret_name](#output_secret_name) | n/a |
<!-- END_TF_DOCS -->