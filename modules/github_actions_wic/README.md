# GitHub Actions Workload Identity Federation Module

Sets up keyless authentication from GitHub Actions to GCP via Workload Identity Federation (WIF) - no service account JSON key ever needs to be stored as a GitHub secret. Creates a Workload Identity Pool + OIDC Provider trusting `token.actions.githubusercontent.com`, a service account, and an IAM binding letting only the specified repository impersonate that service account.

This module only sets up federation - it does **not** grant the resulting service account any project IAM roles (e.g. `roles/run.admin`, `roles/artifactregistry.writer`). Grant whatever roles your workflow actually needs in your own Terraform, using this module's `service_account_email` output.

## Usage

```hcl
module "github_actions_wic" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/github_actions_wic?ref=main"

  project_id        = "my-gcp-project"
  github_repository = "my-org/my-repo"
}

resource "google_project_iam_member" "github_actions_run_admin" {
  project = "my-gcp-project"
  role    = "roles/run.admin"
  member  = "serviceAccount:${module.github_actions_wic.service_account_email}"
}

output "workload_identity_provider" {
  value = module.github_actions_wic.workload_identity_provider
}

output "service_account_email" {
  value = module.github_actions_wic.service_account_email
}
```

Then in the GitHub Actions workflow:

```yaml
permissions:
  contents: read
  id-token: write # required for requesting the OIDC token

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: projects/123456789/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider
          service_account: github-actions@my-gcp-project.iam.gserviceaccount.com
```

### Multiple Repositories

Call the module once per repository - each gets its own pool, provider, and service account, so a compromised workflow in one repo can never impersonate another repo's service account:

```hcl
module "github_actions_wic_backend" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/github_actions_wic?ref=main"

  project_id          = "my-gcp-project"
  github_repository   = "my-org/backend-repo"
  pool_id             = "backend-pool"
  provider_id         = "backend-provider"
  service_account_id  = "backend-deployer"
}

module "github_actions_wic_frontend" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/github_actions_wic?ref=main"

  project_id          = "my-gcp-project"
  github_repository   = "my-org/frontend-repo"
  pool_id             = "frontend-pool"
  provider_id         = "frontend-provider"
  service_account_id  = "frontend-deployer"
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
| github_repository | GitHub repository allowed to authenticate, in 'owner/repo' format | `string` | n/a | yes |
| pool_id | ID for the Workload Identity Pool | `string` | `"github-actions-pool"` | no |
| provider_id | ID for the Workload Identity Pool Provider | `string` | `"github-actions-provider"` | no |
| service_account_id | Account ID (before @) for the service account GitHub Actions will impersonate | `string` | `"github-actions"` | no |
| service_account_display_name | Display name for the service account | `string` | `"GitHub Actions"` | no |

## Outputs

| Name | Description |
|------|-------------|
| service_account_email | Email of the service account GitHub Actions will impersonate |
| workload_identity_provider | Full resource name to pass as `workload_identity_provider` in `google-github-actions/auth` |

## IAM Permissions Required

The identity running Terraform must have:

- `iam.workloadIdentityPools.create` / `.get` / `.update` / `.delete`
- `iam.workloadIdentityPoolProviders.create` / `.get` / `.update` / `.delete`
- `iam.serviceAccounts.create` / `.get` / `.delete`
- `iam.serviceAccounts.setIamPolicy`

These are included in `roles/iam.workloadIdentityPoolAdmin` + `roles/iam.serviceAccountAdmin`, or `roles/owner`.

## Security Notes

- `attribute_condition` restricts federation to the exact repository given - without it, any GitHub Actions workflow on any repository (including ones you don't control) could request tokens claiming to be this pool.
- Consider also restricting by branch/ref (e.g. only `refs/heads/main`) in the calling workflow or by tightening `attribute_condition` further, if a workflow should only be able to deploy from a protected branch.
- Prefer least-privilege role grants on the resulting service account - grant exactly the roles the workflow needs (e.g. `roles/run.admin` + `roles/artifactregistry.writer` + `roles/iam.serviceAccountUser`, scoped down further if practical), not `roles/editor`/`roles/owner`.

## Related Resources

- [Workload Identity Federation Documentation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [google-github-actions/auth](https://github.com/google-github-actions/auth)
