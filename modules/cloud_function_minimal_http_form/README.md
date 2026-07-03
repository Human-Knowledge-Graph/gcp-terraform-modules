# cloud_function_minimal_http_form

A reusable Terraform module for a public HTTP Cloud Function designed to handle HTML form submissions (e.g. a contact form). It provisions the function, CORS configuration, and Secret Manager secret injection — without a load balancer or Cloud Armor, keeping infrastructure cost near zero. The service account is managed externally and passed in.

## Features

- **Cloud Functions Gen 2** — backed by Cloud Run, longer timeouts, better cold-start performance
- **CORS** — allowed origins, methods, and headers passed as environment variables for the function to enforce
- **Secrets injection** — API keys and credentials pulled from Secret Manager at runtime; never stored in Terraform state
- **External service account** — the function's identity is owned and managed outside this module; pass `service_account_email` as a required input
- **Decoupled deployments** — `terraform apply` manages infrastructure; `gcloud functions deploy` updates code independently without state conflicts

## Required GCP APIs

Enable these APIs in your project before running `terraform apply`:

```bash
gcloud services enable \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  secretmanager.googleapis.com \
  storage.googleapis.com
```

## Usage

### Minimal example (javadebadi.com contact form)

```hcl
# 1. Create the service account outside this module
resource "google_service_account" "contact_form_sa" {
  account_id   = "contact-form-sa"
  display_name = "Service account for contact-form Cloud Function"
  project      = "my-gcp-project"
}

# 2. Deploy the function, passing the SA email in
module "contact_form" {
  source = "../../modules/cloud_function_minimal_http_form"

  project_id            = "my-gcp-project"
  region                = "us-central1"
  function_name         = "contact-form"
  service_account_email = google_service_account.contact_form_sa.email

  # Source code — upload your ZIP here before terraform apply
  source_bucket_name   = "my-deployment-artifacts"
  source_object_name   = "contact-form/source.zip"
  create_source_bucket = false  # bucket already exists

  # Runtime
  runtime     = "nodejs20"
  entry_point = "handleRequest"

  # CORS — lock to your domain
  allowed_origins = ["https://javadebadi.com"]

  # Where form submissions are sent (read by the function at runtime)
  notification_email = "javad@javadebadi.com"

  # Secrets — must already exist in Secret Manager
  secrets = [
    {
      env_var_name = "SENDGRID_API_KEY"
      secret_name  = "sendgrid-api-key"
    }
  ]
}

# 3. Grant the SA access to each secret via the module that owns it
module "sendgrid_secret" {
  source = "../../modules/single_secret"

  project_id                = "my-gcp-project"
  secret_name               = "sendgrid-api-key"
  accessor_service_accounts = [google_service_account.contact_form_sa.email]
}

output "contact_form_url" {
  value = module.contact_form.function_url
}
```

### With an existing source bucket created by this module

```hcl
resource "google_service_account" "contact_form_sa" {
  account_id = "contact-form-sa"
  project    = "my-gcp-project"
}

module "contact_form" {
  source = "../../modules/cloud_function_minimal_http_form"

  project_id            = "my-gcp-project"
  region                = "us-central1"
  function_name         = "contact-form"
  service_account_email = google_service_account.contact_form_sa.email

  source_bucket_name   = "contact-form-source-bucket"
  source_object_name   = "source.zip"
  create_source_bucket = true   # Terraform creates the bucket and uploads a placeholder ZIP
  # ...
}
```

## Deployment workflow

Infrastructure and code are intentionally decoupled:

```
# 1. First-time setup — provision all infrastructure and deploy initial code
terraform apply

# 2. Update function code only — no Terraform needed
zip -r source.zip .
gsutil cp source.zip gs://<source_bucket_name>/<source_object_name>
gcloud functions deploy <function_name> \
  --gen2 \
  --region=<region> \
  --source=gs://<source_bucket_name>/<source_object_name>

# 3. Update infrastructure config (env vars, memory, secrets, etc.)
terraform apply   # ignores the current source ZIP, only updates infra
```

Terraform uses `lifecycle { ignore_changes = [build_config[0].source] }` on the function so it never reverts code changes made by `gcloud functions deploy`.

## Environment variables set by this module

The following environment variables are automatically set on the function. Your function code should read and act on them:

| Variable | Example value | Purpose |
|---|---|---|
| `ALLOWED_ORIGINS` | `https://javadebadi.com` | Comma-separated list of CORS origins to allow |
| `ALLOWED_METHODS` | `POST,OPTIONS` | Comma-separated list of allowed HTTP methods |
| `ALLOWED_HEADERS` | `Content-Type` | Comma-separated list of allowed request headers |
| `RATE_LIMIT_REQUESTS` | `10` | Request cap per window (enforced by function code, not infra) |
| `RATE_LIMIT_WINDOW_SECONDS` | `60` | Window size for rate limiting |
| `NOTIFICATION_EMAIL` | `you@example.com` | Destination for form submissions (if set) |

## Variables

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allowed_origins"></a> [allowed_origins](#input_allowed_origins) | List of origins permitted by CORS (e.g. ['https://javadebadi.com']). Passed to the function as the ALLOWED_ORIGINS environment variable (comma-separated). | `list(string)` | n/a | yes |
| <a name="input_function_name"></a> [function_name](#input_function_name) | The name of the Cloud Function (Gen 2). Must be unique within the project and region. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project_id](#input_project_id) | The GCP project ID where the function will be deployed. | `string` | n/a | yes |
| <a name="input_service_account_email"></a> [service_account_email](#input_service_account_email) | Email of the service account the function will run as. Must be created externally before apply. | `string` | n/a | yes |
| <a name="input_source_bucket_name"></a> [source_bucket_name](#input_source_bucket_name) | Name of the Cloud Storage bucket that holds the function source ZIP. Used as both the name when creating and as a reference when not creating. | `string` | n/a | yes |
| <a name="input_source_object_name"></a> [source_object_name](#input_source_object_name) | Path to the source ZIP within the bucket (e.g. 'contact-form/source.zip'). Terraform ignores changes to this after creation; use gcloud functions deploy to update code. | `string` | n/a | yes |
| <a name="input_allow_unauthenticated"></a> [allow_unauthenticated](#input_allow_unauthenticated) | When true, grants allUsers the cloudfunctions.invoker role so the function can be called without authentication. Required for public contact forms. | `bool` | `true` | no |
| <a name="input_allowed_headers"></a> [allowed_headers](#input_allowed_headers) | HTTP request headers the function accepts. Passed as ALLOWED_HEADERS environment variable. | `list(string)` | <pre>[<br/>  "Content-Type"<br/>]</pre> | no |
| <a name="input_allowed_methods"></a> [allowed_methods](#input_allowed_methods) | HTTP methods the function accepts. Passed as ALLOWED_METHODS environment variable. | `list(string)` | <pre>[<br/>  "POST",<br/>  "OPTIONS"<br/>]</pre> | no |
| <a name="input_available_memory"></a> [available_memory](#input_available_memory) | Memory available to the function (e.g. '256M', '512M', '1G', '2G'). | `string` | `"256M"` | no |
| <a name="input_create_source_bucket"></a> [create_source_bucket](#input_create_source_bucket) | When true, Terraform creates the source bucket. When false, the bucket is expected to already exist. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input_description) | Human-readable description for the Cloud Function. | `string` | `""` | no |
| <a name="input_entry_point"></a> [entry_point](#input_entry_point) | The name of the exported function in the source code that Cloud Functions invokes. | `string` | `"handleRequest"` | no |
| <a name="input_environment_variables"></a> [environment_variables](#input_environment_variables) | Additional plain-text environment variables to set on the function. Do not use for sensitive values — use var.secrets instead. | `map(string)` | `{}` | no |
| <a name="input_ingress_settings"></a> [ingress_settings](#input_ingress_settings) | Controls which traffic can reach the function. 'ALLOW_ALL' for public access, 'ALLOW_INTERNAL_ONLY' to restrict to VPC and Cloud Run invocations. | `string` | `"ALLOW_ALL"` | no |
| <a name="input_max_instances"></a> [max_instances](#input_max_instances) | Maximum number of concurrent function instances. | `number` | `10` | no |
| <a name="input_min_instances"></a> [min_instances](#input_min_instances) | Minimum number of function instances to keep warm (0 = scale to zero). | `number` | `0` | no |
| <a name="input_notification_email"></a> [notification_email](#input_notification_email) | Email address to receive form submissions. Passed as NOTIFICATION_EMAIL environment variable. Leave empty to omit. | `string` | `""` | no |
| <a name="input_rate_limit_requests_per_minute"></a> [rate_limit_requests_per_minute](#input_rate_limit_requests_per_minute) | Passed to the function as RATE_LIMIT_REQUESTS env var. The function code is responsible for enforcing this limit (e.g. via Firestore or reCAPTCHA). No infrastructure-level rate limiting is created by this module. | `number` | `10` | no |
| <a name="input_region"></a> [region](#input_region) | The region for the Cloud Function. | `string` | `"us-central1"` | no |
| <a name="input_runtime"></a> [runtime](#input_runtime) | The Cloud Functions runtime (e.g. 'nodejs20', 'python312', 'go122'). | `string` | `"nodejs20"` | no |
| <a name="input_secrets"></a> [secrets](#input_secrets) | Secrets from Secret Manager to inject as environment variables. Each secret must already exist in Secret Manager before apply. | <pre>list(object({<br/>    env_var_name = string<br/>    secret_name  = string<br/>    version      = optional(string, "latest")<br/>  }))</pre> | `[]` | no |
| <a name="input_timeout_seconds"></a> [timeout_seconds](#input_timeout_seconds) | Maximum duration in seconds for a single function invocation. | `number` | `60` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_function_name"></a> [function_name](#output_function_name) | The name of the deployed Cloud Function. Use this with gcloud functions deploy to push code updates. |
| <a name="output_function_url"></a> [function_url](#output_function_url) | The HTTPS URL of the Cloud Function. Use this as the action endpoint in your contact form. |
| <a name="output_service_account_email"></a> [service_account_email](#output_service_account_email) | Pass-through of var.service_account_email. Useful for wiring into downstream modules (e.g. single_secret) without repeating the value. |
| <a name="output_source_bucket_name"></a> [source_bucket_name](#output_source_bucket_name) | Name of the Cloud Storage bucket holding the function source ZIP. Only meaningful when create_source_bucket = true. |
<!-- END_TF_DOCS -->

## Notes

- **Rate limiting** is configured via environment variables only. The function code is responsible for enforcement (e.g. using reCAPTCHA or Firestore-based counters). No load balancer or Cloud Armor is created by this module.
- **Service account is required and must be created externally.** This module does not create an SA. Pass its email via `service_account_email` and grant it permissions (e.g. `roles/secretmanager.secretAccessor`) via the modules that own those resources.
- **Secrets must exist before `terraform apply`**, and IAM access must be granted separately. This module does **not** grant `roles/secretmanager.secretAccessor` — use the `single_secret` module (which owns each secret) to grant access.
- **CORS is enforced by your function code**, not by GCP infrastructure. The `ALLOWED_ORIGINS` env var is a convention; make sure your function reads it and sets the appropriate response headers.
