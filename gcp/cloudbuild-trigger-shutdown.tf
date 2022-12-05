# Create Cloud Build trigger to start VM again
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger
resource "google_cloudbuild_trigger" "shutdown" {
  project     = google_project.my.project_id
  name        = "gce-on-again"
  description = "Pub/Sub trigger to turn GCE VM back on again (Terraform managed)"

  pubsub_config {
    topic = google_pubsub_topic.logsink.id
  }

  // Google Cloud Source repository
  source_to_build {
    uri = google_sourcerepo_repository.repo.url
    ref = var.cloud-build-source-repo-revision
    # UNKNOWN, CLOUD_SOURCE_REPOSITORIES, GITHUB
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }
  git_file_source {
    path      = "cloudbuild/on-again.yml"
    uri       = google_sourcerepo_repository.repo.url
    revision  = var.cloud-build-source-repo-revision
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }

  # https://cloud.google.com/build/docs/automate-builds-pubsub-events
  substitutions = {
    _JSON_BODY   = "$(body.message)"
    _INSTANCE_ID = "$(body.message.data.resource.labels.instance_id)"
    _PROJECT_ID  = "$(body.message.data.resource.labels.project_id)"
    _ZONE        = "$(body.message.data.resource.labels.zone)"
  }

  # Common Expression Language filter
  # https://github.com/google/cel-spec/blob/master/doc/langdef.md#list-of-standard-definitions
  filter = "_JSON_BODY.contains('Instance terminated by guest OS shutdown.')"
}