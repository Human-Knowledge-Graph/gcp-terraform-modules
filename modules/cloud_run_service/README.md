# Cloud Run Service Module

This module creates a Google Cloud Run service with container deployment and configurable IAM access permissions.

## Features

- Deploy containerized applications to Cloud Run
- Configure environment variables dynamically
- Control access with IAM bindings for service invokers
- Configure resource limits (CPU and memory)
- Autoscaling with min/max instance controls
- Custom service accounts for security
- Ingress controls (public, internal, or load balancer only)
- Request timeout and concurrency configuration
- Custom container port support
- Cloud SQL database connections

## Usage

Reference this module using a Git commit hash for version control:

```hcl
module "cloud_run_service" {
  # Pin to specific commit - check CHANGELOG.md for latest stable commits
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/cloud_run_service?ref=13e32d9"

  project_id             = "my-gcp-project"
  region                 = "us-central1"
  cloud_run_service_name = "my-api-service"
  image                  = "gcr.io/my-project/my-app:latest"

  env_vars = {
    DATABASE_URL = "postgresql://..."
    API_KEY      = "secret-value"
  }

  allowed_invoker_members = [
    "allUsers"  # Public access
  ]
}
```

> **Finding the right commit:** Check this module's [CHANGELOG.md](./CHANGELOG.md) for stable commit hashes, or use `git log modules/cloud_run_service` to see recent changes.

### Basic Example - Public Web Service

```hcl
module "web_app" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/cloud_run_service?ref=13e32d9"

  project_id             = "my-gcp-project"
  region                 = "us-central1"
  cloud_run_service_name = "web-app"
  image                  = "gcr.io/my-project/web-app:v1.0.0"

  env_vars = {
    ENVIRONMENT = "production"
    PORT        = "8080"
  }

  allowed_invoker_members = [
    "allUsers"
  ]
}

output "app_url" {
  value = module.web_app.service_url
}
```

### Private API Service

```hcl
module "api_service" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/cloud_run_service?ref=13e32d9"

  project_id             = "my-gcp-project"
  region                 = "us-west1"
  cloud_run_service_name = "internal-api"
  image                  = "gcr.io/my-project/api:latest"

  env_vars = {
    DATABASE_HOST = "10.0.0.5"
    CACHE_URL     = "redis://cache:6379"
  }

  # Only allow specific service accounts
  allowed_invoker_members = [
    "serviceAccount:frontend@my-project.iam.gserviceaccount.com",
    "serviceAccount:worker@my-project.iam.gserviceaccount.com"
  ]
}
```

### Service with Multiple Environment Variables

```hcl
module "backend_service" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/cloud_run_service?ref=13e32d9"

  project_id             = var.project_id
  region                 = "europe-west1"
  cloud_run_service_name = "backend"
  image                  = "gcr.io/${var.project_id}/backend:${var.version}"

  env_vars = {
    NODE_ENV           = "production"
    DATABASE_URL       = var.database_url
    REDIS_URL          = var.redis_url
    API_KEY            = var.api_key
    LOG_LEVEL          = "info"
    MAX_CONNECTIONS    = "100"
    TIMEOUT_SECONDS    = "30"
  }

  allowed_invoker_members = [
    "allUsers"
  ]
}
```

### Production Service with Resource Limits and Autoscaling

```hcl
module "production_api" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/cloud_run_service?ref=13e32d9"

  project_id             = "my-gcp-project"
  region                 = "us-central1"
  cloud_run_service_name = "production-api"
  image                  = "gcr.io/my-project/api:v2.0.0"

  # Resource limits
  cpu_limit    = "2000m"  # 2 vCPUs
  memory_limit = "1Gi"    # 1GB RAM

  # Autoscaling
  min_instances = "1"    # Always keep 1 instance warm (reduces cold starts)
  max_instances = "50"   # Scale up to 50 instances under load

  # Concurrency and timeout
  container_concurrency = 100
  timeout_seconds       = 60

  # Custom service account for security
  service_account_email = "api-service@my-project.iam.gserviceaccount.com"

  env_vars = {
    ENVIRONMENT = "production"
  }

  allowed_invoker_members = ["allUsers"]
}
```

### Internal-Only Service with Load Balancer Access

```hcl
module "internal_service" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/cloud_run_service?ref=13e32d9"

  project_id             = "my-gcp-project"
  region                 = "us-east1"
  cloud_run_service_name = "internal-backend"
  image                  = "gcr.io/my-project/backend:latest"

  # Restrict ingress to internal traffic and Cloud Load Balancing
  ingress = "internal-and-cloud-load-balancing"

  # Lightweight service
  cpu_limit    = "1000m"
  memory_limit = "256Mi"

  # Scale to zero when not in use
  min_instances = "0"
  max_instances = "10"

  env_vars = {
    INTERNAL = "true"
  }

  allowed_invoker_members = [
    "serviceAccount:frontend@my-project.iam.gserviceaccount.com"
  ]
}
```

### High-Performance Service

```hcl
module "high_performance_api" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/cloud_run_service?ref=13e32d9"

  project_id             = "my-gcp-project"
  region                 = "us-west1"
  cloud_run_service_name = "fast-api"
  image                  = "gcr.io/my-project/fast-api:latest"

  # Maximum resources
  cpu_limit    = "4000m"  # 4 vCPUs
  memory_limit = "4Gi"    # 4GB RAM

  # High concurrency
  container_concurrency = 250

  # Always keep instances warm
  min_instances = "5"
  max_instances = "100"

  # Custom port
  container_port = 3000

  # Longer timeout for complex operations
  timeout_seconds = 600

  env_vars = {
    NODE_ENV = "production"
  }

  allowed_invoker_members = ["allUsers"]
}
```

### Using with Static IP

```hcl
# Create static IP
module "static_ip" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/static_ip?ref=efa9048"

  project_id = var.project_id
  name       = "service-ip"
  region     = "us-central1"
}

# Deploy Cloud Run service
module "service" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/cloud_run_service?ref=13e32d9"

  project_id             = var.project_id
  region                 = "us-central1"
  cloud_run_service_name = "my-service"
  image                  = "gcr.io/my-project/app:latest"

  env_vars = {
    STATIC_IP = module.static_ip.ip_address
  }

  allowed_invoker_members = ["allUsers"]
}
```

### Service with Cloud SQL Connection

```hcl
module "backend_with_database" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/cloud_run_service?ref=13e32d9"

  project_id             = "my-gcp-project"
  region                 = "us-central1"
  cloud_run_service_name = "backend-api"
  image                  = "gcr.io/my-project/backend:latest"

  # Connect to Cloud SQL instance
  cloudsql_instances = "my-gcp-project:us-central1:my-postgres-instance"

  # Service account needs Cloud SQL Client role
  service_account_email = "backend@my-gcp-project.iam.gserviceaccount.com"

  env_vars = {
    DB_HOST = "/cloudsql/my-gcp-project:us-central1:my-postgres-instance"
    DB_NAME = "production"
    DB_USER = "app_user"
  }

  allowed_invoker_members = ["allUsers"]
}
```

### Service with Multiple Cloud SQL Instances

```hcl
module "multi_database_service" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/cloud_run_service?ref=13e32d9"

  project_id             = "my-gcp-project"
  region                 = "us-central1"
  cloud_run_service_name = "data-processor"
  image                  = "gcr.io/my-project/processor:latest"

  # Connect to multiple Cloud SQL instances (comma-separated)
  cloudsql_instances = "my-gcp-project:us-central1:postgres-db,my-gcp-project:us-central1:mysql-db"

  service_account_email = "processor@my-gcp-project.iam.gserviceaccount.com"

  env_vars = {
    POSTGRES_HOST = "/cloudsql/my-gcp-project:us-central1:postgres-db"
    MYSQL_HOST    = "/cloudsql/my-gcp-project:us-central1:mysql-db"
  }

  allowed_invoker_members = ["allUsers"]
}
```

### Outputs Usage

```hcl
module "api" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/cloud_run_service?ref=13e32d9"

  project_id             = var.project_id
  region                 = var.region
  cloud_run_service_name = "api"
  image                  = var.image
  env_vars               = var.env_vars
  allowed_invoker_members = ["allUsers"]
}

output "service_url" {
  description = "URL to access the Cloud Run service"
  value       = module.api.service_url
}

output "service_name" {
  description = "Name of the deployed service"
  value       = module.api.service_name
}

output "service_id" {
  description = "Full resource ID"
  value       = module.api.service_id
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
| <a name="input_allowed_invoker_members"></a> [allowed_invoker_members](#input_allowed_invoker_members) | List of members allowed to invoke the Cloud Run service | `list(string)` | n/a | yes |
| <a name="input_cloud_run_service_name"></a> [cloud_run_service_name](#input_cloud_run_service_name) | Name of the default Cloud Run Service | `string` | n/a | yes |
| <a name="input_env_vars"></a> [env_vars](#input_env_vars) | Environment variables as pairs of key, values | `map(string)` | n/a | yes |
| <a name="input_image"></a> [image](#input_image) | Container image location | `string` | n/a | yes |
| <a name="input_project_id"></a> [project_id](#input_project_id) | The unique ID of the project. | `string` | n/a | yes |
| <a name="input_client_name"></a> [client_name](#input_client_name) | Client name annotation (e.g., 'terraform', 'gcloud', 'console'). Used to track which tool deployed the service | `string` | `"terraform"` | no |
| <a name="input_client_version"></a> [client_version](#input_client_version) | Client version annotation. Version of the tool used to deploy (e.g., Terraform version, gcloud version) | `string` | `null` | no |
| <a name="input_cloudsql_instances"></a> [cloudsql_instances](#input_cloudsql_instances) | Cloud SQL instance connection names to connect to (format: project:region:instance). Separate multiple instances with commas | `string` | `null` | no |
| <a name="input_container_concurrency"></a> [container_concurrency](#input_container_concurrency) | Maximum number of concurrent requests per container instance | `number` | `80` | no |
| <a name="input_container_port"></a> [container_port](#input_container_port) | Port that the container listens on | `number` | `8080` | no |
| <a name="input_cpu_limit"></a> [cpu_limit](#input_cpu_limit) | CPU limit for the container (e.g., '1000m' for 1 vCPU, '2000m' for 2 vCPUs) | `string` | `"1000m"` | no |
| <a name="input_ingress"></a> [ingress](#input_ingress) | Ingress settings for the service: 'all', 'internal', or 'internal-and-cloud-load-balancing' | `string` | `"all"` | no |
| <a name="input_max_instances"></a> [max_instances](#input_max_instances) | Maximum number of container instances to scale to | `string` | `"100"` | no |
| <a name="input_memory_limit"></a> [memory_limit](#input_memory_limit) | Memory limit for the container (e.g., '256Mi', '512Mi', '1Gi', '2Gi') | `string` | `"512Mi"` | no |
| <a name="input_min_instances"></a> [min_instances](#input_min_instances) | Minimum number of container instances to keep running | `string` | `"0"` | no |
| <a name="input_region"></a> [region](#input_region) | The region for the project. | `string` | `"us-central1"` | no |
| <a name="input_service_account_email"></a> [service_account_email](#input_service_account_email) | Service account email to run the Cloud Run service as. If not provided, uses the default Compute Engine service account | `string` | `null` | no |
| <a name="input_timeout_seconds"></a> [timeout_seconds](#input_timeout_seconds) | Maximum duration in seconds for each request | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_id"></a> [service_id](#output_service_id) | The ID of the Cloud Run service |
| <a name="output_service_name"></a> [service_name](#output_service_name) | The name of the Cloud Run service |
| <a name="output_service_url"></a> [service_url](#output_service_url) | The URL of the Cloud Run service |
<!-- END_TF_DOCS -->

## IAM Permissions Required

The service account or user running Terraform must have the following permissions:

- `run.services.create`
- `run.services.get`
- `run.services.update`
- `run.services.delete`
- `run.services.setIamPolicy`
- `run.services.getIamPolicy`
- `iam.serviceAccounts.actAs` (if using a custom service account)

These are included in the following predefined roles:
- `roles/run.admin`
- `roles/editor`
- `roles/owner`

## Common Invoker Members

### Public Access
```hcl
allowed_invoker_members = ["allUsers"]
```

### Authenticated Users Only
```hcl
allowed_invoker_members = ["allAuthenticatedUsers"]
```

### Specific Service Accounts
```hcl
allowed_invoker_members = [
  "serviceAccount:frontend@my-project.iam.gserviceaccount.com",
  "serviceAccount:api@my-project.iam.gserviceaccount.com"
]
```

### Specific Users
```hcl
allowed_invoker_members = [
  "user:developer@example.com",
  "user:admin@example.com"
]
```

### Groups
```hcl
allowed_invoker_members = [
  "group:backend-team@example.com"
]
```

### Mixed Members
```hcl
allowed_invoker_members = [
  "serviceAccount:app@my-project.iam.gserviceaccount.com",
  "user:admin@example.com",
  "group:devops@example.com"
]
```

## Notes

- **Cloud Run API:** Ensure the Cloud Run API (`run.googleapis.com`) is enabled in your project
- **Container Registry:** Images must be accessible from the project (GCR, Artifact Registry, or public registries)
- **Environment Variables:** Sensitive values should be passed via Terraform variables marked as `sensitive = true` or use Secret Manager
- **IAM Binding:** Uses authoritative binding - replaces all existing invoker permissions
- **Default Region:** Defaults to `us-central1` if not specified
- **Automatic HTTPS:** Cloud Run automatically provisions HTTPS certificates for custom domains
- **Cold Starts:** First request after deployment may be slower due to container startup

## Best Practices

- Use specific image tags instead of `latest` for production deployments
- Store sensitive environment variables in Secret Manager and reference them
- Use least privilege IAM - avoid `allUsers` for internal services
- Set up CI/CD to automate deployments
- Use health checks and readiness probes for production services
- Monitor service metrics and logs in Cloud Monitoring
- Consider using VPC connectors for private network access
- Enable Cloud Run revisions for easy rollback

## Container Image Sources

Cloud Run supports images from:
- **Google Container Registry (GCR):** `gcr.io/PROJECT_ID/IMAGE:TAG`
- **Artifact Registry:** `REGION-docker.pkg.dev/PROJECT_ID/REPO/IMAGE:TAG`
- **Docker Hub:** `docker.io/library/IMAGE:TAG`
- **Other registries:** Any accessible container registry

## Environment Variables Security

For sensitive values, use Secret Manager:

```hcl
# Create secret (use single_secret module)
module "db_password" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/single_secret?ref=0b74c7b"

  secret_id = "database-password"
  service_account_with_access_permissions = [
    "serviceAccount:cloud-run-sa@my-project.iam.gserviceaccount.com"
  ]
}

# Reference in Cloud Run
# Note: This module doesn't support secret references yet
# You would need to extend the module or pass the secret ID as an env var
```

## Related Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud Run Pricing](https://cloud.google.com/run/pricing)
- [Container Runtime Contract](https://cloud.google.com/run/docs/container-contract)
- [Cloud Run IAM Roles](https://cloud.google.com/run/docs/reference/iam/roles)
