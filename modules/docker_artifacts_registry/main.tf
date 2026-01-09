locals {
  delete_older_than_seconds = "${var.delete_older_than_days * 86400}s"
}

resource "google_artifact_registry_repository" "this" {
  location               = var.location
  project                = var.project_id
  repository_id          = var.artifacts_repository_id
  description            = var.description
  format                 = "DOCKER"
  cleanup_policy_dry_run = var.cleanup_policy_dry_run
  cleanup_policies {
    id     = "delete-old-tagged"
    action = "DELETE"
    condition {
      tag_state    = "TAGGED"
      tag_prefixes = var.tags_to_delete_after_a_month
      older_than   = local.delete_older_than_seconds
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