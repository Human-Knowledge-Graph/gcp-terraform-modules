resource "google_artifact_registry_repository" "my-repo" {
  location               = var.location
  project                = var.project_id
  repository_id          = var.artifacts_repository_id
  description            = var.description
  format                 = "DOCKER"
  cleanup_policy_dry_run = false
  cleanup_policies {
    id     = "delete-after-a-month"
    action = "DELETE"
    condition {
      tag_state    = "TAGGED"
      tag_prefixes = var.tags_to_delete_after_a_month
      older_than   = "2592000s"
    }
  }
  cleanup_policies {
    id     = "keep-tagged-release"
    action = "KEEP"
    condition {
      tag_state             = "TAGGED"
      tag_prefixes          = var.tags_to_keep_forever
      package_name_prefixes = []
    }
  }
  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      package_name_prefixes = []
      keep_count            = var.count_of_versions_to_keep
    }
  }
}