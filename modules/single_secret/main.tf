resource "google_secret_manager_secret" "single_secret" {
  secret_id = var.secret_id
  replication {
    auto {}
  }
}

# Grant the service accounts access to the secret using an IAM binding
resource "google_secret_manager_secret_iam_binding" "single_secret_access_permissions" {
  secret_id = google_secret_manager_secret.single_secret.id
  role      = "roles/secretmanager.secretAccessor"
  members   = var.service_account_with_access_permissions

}