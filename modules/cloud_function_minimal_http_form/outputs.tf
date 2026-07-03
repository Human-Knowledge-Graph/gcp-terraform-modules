output "function_url" {
  description = "The HTTPS URL of the Cloud Function. Use this as the action endpoint in your contact form."
  value       = google_cloudfunctions2_function.function.service_config[0].uri
}

output "function_name" {
  description = "The name of the deployed Cloud Function. Use this with gcloud functions deploy to push code updates."
  value       = google_cloudfunctions2_function.function.name
}

output "service_account_email" {
  description = "Email of the function's dedicated service account. Use this to grant additional GCP permissions the function may need (e.g. Firestore access for rate limiting)."
  value       = var.service_account_email
}

output "source_bucket_name" {
  description = "Name of the Cloud Storage bucket holding the function source ZIP. Only meaningful when create_source_bucket = true."
  value       = local.source_bucket
}
