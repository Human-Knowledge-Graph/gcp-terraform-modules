output "service_account_email" {
  description = "Email of the service account GitHub Actions will impersonate - grant this IAM roles in the calling project"
  value       = google_service_account.github_actions.email
}

output "workload_identity_provider" {
  description = "Full resource name to pass as workload_identity_provider in google-github-actions/auth"
  value       = google_iam_workload_identity_pool_provider.github_actions.name
}
