# Create Cloud Build trigger to destroy build
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger
resource "google_cloudbuild_trigger" "destroy" {
  project     = google_project.my.project_id
  name        = "destroy-build"
  description = "Pub/Sub trigger to destroy build (Terraform managed)"

  pubsub_config {
    topic = google_pubsub_topic.destroy.id
  }

  // Google Cloud Source repository
  source_to_build {
    uri = google_sourcerepo_repository.repo.url
    ref = var.cloud-build-source-repo-revision
    # UNKNOWN, CLOUD_SOURCE_REPOSITORIES, GITHUB
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }
  git_file_source {
    path      = "cloudbuild/destroy.yml"
    uri       = google_sourcerepo_repository.repo.url
    revision  = var.cloud-build-source-repo-revision
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }

  # https://cloud.google.com/build/docs/automate-builds-pubsub-events
  substitutions = {
    _JSON_BODY     = "$(body.message)"
    _DESTROY_BUILD = "$(body.message.data.destroy)"
    _STATE_BUCKET  = "${google_storage_bucket.state.name}"
  }

  # Common Expression Language filter
  # https://github.com/google/cel-spec/blob/master/doc/langdef.md#list-of-standard-definitions
  filter = "_JSON_BODY.contains('destroy')"
}