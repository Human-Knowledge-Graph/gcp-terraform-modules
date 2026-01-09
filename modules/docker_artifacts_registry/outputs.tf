output "repository_id" {
  value       = google_artifact_registry_repository.my-repo.id
  description = "Id of the repository"
}
output "repository_name" {
  value       = google_artifact_registry_repository.my-repo.name
  description = "name of the repository"
}
