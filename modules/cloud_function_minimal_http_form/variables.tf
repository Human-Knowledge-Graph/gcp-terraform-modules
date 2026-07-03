# ── Core ──────────────────────────────────────────────────────────────────────

variable "project_id" {
  description = "The GCP project ID where the function will be deployed."
  type        = string
}

variable "region" {
  description = "The region for the Cloud Function."
  type        = string
  default     = "us-central1"
}

variable "function_name" {
  description = "The name of the Cloud Function (Gen 2). Must be unique within the project and region."
  type        = string
}

variable "description" {
  description = "Human-readable description for the Cloud Function."
  type        = string
  default     = ""
}

variable "service_account_email" {
  description = "Email of the service account the function will run as. The SA must be created externally (e.g. via the single_secret module or a dedicated SA module)."
  type        = string
}

# ── Source Code ───────────────────────────────────────────────────────────────

variable "source_bucket_name" {
  description = "Name of the Cloud Storage bucket that holds the function source ZIP. Used as both the name when creating and as a reference when not creating."
  type        = string
}

variable "source_object_name" {
  description = "Path to the source ZIP within the bucket (e.g. 'contact-form/source.zip'). Terraform ignores changes to this after creation; use gcloud functions deploy to update code."
  type        = string
}

variable "create_source_bucket" {
  description = "When true, Terraform creates the source bucket. When false, the bucket is expected to already exist."
  type        = bool
  default     = false
}

# ── Build Config ──────────────────────────────────────────────────────────────

variable "runtime" {
  description = "The Cloud Functions runtime (e.g. 'nodejs20', 'python312', 'go122')."
  type        = string
  default     = "nodejs20"
}

variable "entry_point" {
  description = "The name of the exported function in the source code that Cloud Functions invokes."
  type        = string
  default     = "handleRequest"
}

# ── Service Config ────────────────────────────────────────────────────────────

variable "available_memory" {
  description = "Memory available to the function (e.g. '256M', '512M', '1G', '2G')."
  type        = string
  default     = "256M"
}

variable "timeout_seconds" {
  description = "Maximum duration in seconds for a single function invocation."
  type        = number
  default     = 60
}

variable "min_instances" {
  description = "Minimum number of function instances to keep warm (0 = scale to zero)."
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of concurrent function instances."
  type        = number
  default     = 10
}

variable "ingress_settings" {
  description = "Controls which traffic can reach the function. 'ALLOW_ALL' for public access, 'ALLOW_INTERNAL_ONLY' to restrict to VPC and Cloud Run invocations."
  type        = string
  default     = "ALLOW_ALL"

  validation {
    condition     = contains(["ALLOW_ALL", "ALLOW_INTERNAL_ONLY"], var.ingress_settings)
    error_message = "ingress_settings must be one of: 'ALLOW_ALL' or 'ALLOW_INTERNAL_ONLY'."
  }
}

# ── CORS ──────────────────────────────────────────────────────────────────────

variable "allowed_origins" {
  description = "List of origins permitted by CORS (e.g. ['https://javadebadi.com']). Passed to the function as the ALLOWED_ORIGINS environment variable (comma-separated)."
  type        = list(string)
}

variable "allowed_methods" {
  description = "HTTP methods the function accepts. Passed as ALLOWED_METHODS environment variable."
  type        = list(string)
  default     = ["POST", "OPTIONS"]
}

variable "allowed_headers" {
  description = "HTTP request headers the function accepts. Passed as ALLOWED_HEADERS environment variable."
  type        = list(string)
  default     = ["Content-Type"]
}

# ── Secrets ───────────────────────────────────────────────────────────────────

variable "secrets" {
  description = "Secrets from Secret Manager to inject as environment variables. Each secret must already exist in Secret Manager before apply."
  type = list(object({
    env_var_name = string
    secret_name  = string
    version      = optional(string, "latest")
  }))
  default = []
}

# ── Environment Variables ─────────────────────────────────────────────────────

variable "environment_variables" {
  description = "Additional plain-text environment variables to set on the function. Do not use for sensitive values — use var.secrets instead."
  type        = map(string)
  default     = {}
}

variable "notification_email" {
  description = "Email address to receive form submissions. Passed as NOTIFICATION_EMAIL environment variable. Leave empty to omit."
  type        = string
  default     = ""
}

# ── Access Control ────────────────────────────────────────────────────────────

variable "allow_unauthenticated" {
  description = "When true, grants allUsers the cloudfunctions.invoker role so the function can be called without authentication. Required for public contact forms."
  type        = bool
  default     = true
}

# ── Rate Limiting ─────────────────────────────────────────────────────────────

variable "rate_limit_requests_per_minute" {
  description = "Passed to the function as RATE_LIMIT_REQUESTS env var. The function code is responsible for enforcing this limit (e.g. via Firestore or reCAPTCHA). No infrastructure-level rate limiting is created by this module."
  type        = number
  default     = 10
}
