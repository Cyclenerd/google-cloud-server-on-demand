# Create Cloud Build trigger to create build (VM)
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger
resource "google_cloudbuild_trigger" "create" {
  project     = google_project.my.project_id
  name        = "create-build"
  description = "Pub/Sub trigger to create build (Terraform managed)"

  pubsub_config {
    topic = google_pubsub_topic.create.id
  }

  // Google Cloud Source repository
  source_to_build {
    uri = google_sourcerepo_repository.repo.url
    ref = var.cloud-build-source-repo-revision
    # UNKNOWN, CLOUD_SOURCE_REPOSITORIES, GITHUB
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }
  git_file_source {
    path      = "cloudbuild/create.yml"
    uri       = google_sourcerepo_repository.repo.url
    revision  = var.cloud-build-source-repo-revision
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }

  # https://cloud.google.com/build/docs/automate-builds-pubsub-events
  substitutions = {
    _JSON_DATA    = "$(body.message.data)"
    _STATE_BUCKET = "${google_storage_bucket.state.name}"
  }

  # Common Expression Language filter
  # https://github.com/google/cel-spec/blob/master/doc/langdef.md#list-of-standard-definitions
  filter = "_JSON_DATA.contains('image') && _JSON_DATA.contains('username') && _JSON_DATA.contains('password') && _JSON_DATA.contains('dnsname')"
}