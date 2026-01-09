output "repository_id" {
  value       = google_artifact_registry_repository.this.id
  description = "Id of the repository"
}

output "repository_name" {
  value       = google_artifact_registry_repository.this.name
  description = "Name of the repository"
}
