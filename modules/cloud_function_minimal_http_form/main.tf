locals {
  source_bucket = var.create_source_bucket ? google_storage_bucket.source[0].name : var.source_bucket_name

  placeholder_source = {
    "python" = "def ${var.entry_point}(request):\n    return 'OK', 200\n"
    "nodejs" = "exports.${var.entry_point} = (req, res) => res.send('OK');\n"
  }
  runtime_family = regex("^([a-z]+)", var.runtime)[0]

  # CORS and rate-limit config passed as env vars; the function code is responsible for acting on them
  framework_env_vars = {
    ALLOWED_ORIGINS           = join(",", var.allowed_origins)
    ALLOWED_METHODS           = join(",", var.allowed_methods)
    ALLOWED_HEADERS           = join(",", var.allowed_headers)
    RATE_LIMIT_REQUESTS       = tostring(var.rate_limit_requests_per_minute)
    RATE_LIMIT_WINDOW_SECONDS = "60"
  }

  notification_env_var = var.notification_email != "" ? { NOTIFICATION_EMAIL = var.notification_email } : {}

  # User-supplied vars override framework defaults if keys collide
  effective_env_vars = merge(local.framework_env_vars, local.notification_env_var, var.environment_variables)
}

# ── Source Bucket (optional) ──────────────────────────────────────────────────
#
# Cloud Functions Gen 2 cannot take inline code. It requires the source as a ZIP
# in a Cloud Storage bucket. The flow is:
#
#   1. You upload a ZIP of your function code to this bucket (manually or via CI).
#   2. Terraform creates the function pointing at bucket + object path.
#   3. GCP Cloud Build pulls the ZIP, builds a container image, and deploys it.
#
# The bucket does NOT trigger the function — it is just a source repository.
# Uploading a new ZIP does not redeploy automatically; use `gcloud functions deploy`
# or this Terraform resource's `source_object_name` variable to do that.
#
# Set create_source_bucket = false if you already have a shared artifacts bucket.
# Versioning is enabled so you keep a history of every deployed ZIP.

resource "google_storage_bucket" "source" {
  count    = var.create_source_bucket ? 1 : 0
  name     = var.source_bucket_name
  location = var.region
  project  = var.project_id

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

# ── Placeholder Source ZIP ────────────────────────────────────────────────────
#
# When this module creates the bucket it also needs a valid ZIP in place before
# the function can be deployed. archive_file generates a minimal stub locally;
# google_storage_bucket_object uploads it on first apply.
#
# The lifecycle ignore_changes ensures that once real code is pushed (via
# gcloud functions deploy or CI), Terraform never overwrites it on subsequent
# applies. The same ignore_changes on the function's build_config[0].source
# means the function itself also won't revert to the placeholder.

data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "/tmp/${var.function_name}-placeholder.zip"

  source {
    content  = lookup(local.placeholder_source, local.runtime_family, "exports.${var.entry_point} = (req, res) => res.send('OK');\n")
    filename = local.runtime_family == "python" ? "main.py" : "index.js"
  }
}

resource "google_storage_bucket_object" "placeholder_source" {
  count  = var.create_source_bucket ? 1 : 0
  name   = var.source_object_name
  bucket = local.source_bucket
  source = data.archive_file.placeholder.output_path

  lifecycle {
    ignore_changes = [source, detect_md5hash]
  }
}

# ── Cloud Function (Gen 2) ────────────────────────────────────────────────────
#
# Gen 2 functions run on Cloud Run under the hood and support longer timeouts,
# more memory, and concurrency compared to Gen 1.
#
# The resource is split into two blocks:
#   build_config   — how GCP compiles/packages the function (one-time per deploy)
#   service_config — how the running function behaves (memory, env vars, secrets)

resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.region
  project     = var.project_id
  description = var.description

  # build_config: tells Cloud Build how to turn the ZIP into a runnable container.
  # Points at the ZIP in Cloud Storage. After first creation, the source field is
  # intentionally ignored (see lifecycle below) so gcloud functions deploy can
  # push new code without conflicting with Terraform state.
  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point

    source {
      storage_source {
        bucket = local.source_bucket
        object = var.source_object_name
      }
    }
  }

  service_config {
    min_instance_count             = var.min_instances
    max_instance_count             = var.max_instances
    timeout_seconds                = var.timeout_seconds
    available_memory               = var.available_memory
    service_account_email          = var.service_account_email
    all_traffic_on_latest_revision = true

    ingress_settings = var.ingress_settings

    # Plain-text env vars: CORS origins, allowed methods/headers, rate limit
    # config, and notification email. The function code reads these at runtime.
    environment_variables = local.effective_env_vars

    # Secrets from Secret Manager are injected as env vars at runtime.
    # GCP decrypts them inside the execution environment — they never appear
    # in Terraform state or plan output.
    dynamic "secret_environment_variables" {
      for_each = var.secrets
      content {
        key        = secret_environment_variables.value.env_var_name
        project_id = var.project_id
        secret     = secret_environment_variables.value.secret_name
        version    = secret_environment_variables.value.version
      }
    }
  }

  # Decouple infrastructure from code: Terraform sets the source ZIP once at
  # creation. After that, gcloud functions deploy can update the code freely
  # and Terraform will not try to revert it on the next apply.
  lifecycle {
    ignore_changes = [
      build_config[0].source,
    ]
  }

  depends_on = [google_storage_bucket_object.placeholder_source]
}

# ── IAM: Public Invocation ────────────────────────────────────────────────────
#
# By default, Cloud Functions Gen 2 requires a Google identity (Bearer token)
# to invoke it. This binding makes the function publicly callable — no auth
# token required — which is necessary for a browser-based contact form.
#
# "allUsers" is a special GCP member meaning anyone on the internet.
# Set allow_unauthenticated = false to remove this binding and lock the
# function down (e.g. during maintenance or if you move to server-side calls).

resource "google_cloudfunctions2_function_iam_member" "public_invoker" {
  count          = var.allow_unauthenticated ? 1 : 0
  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
