# Create Cloud Build trigger to copy Docker image to Artifact Registry repository
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger
resource "google_cloudbuild_trigger" "copy-image" {
  project     = google_project.my.project_id
  name        = "copy-image"
  description = "Trigger to copy Docker image to Artifact Registry repository (Terraform managed)"

  // Google Cloud Source repository
  source_to_build {
    uri = google_sourcerepo_repository.repo.url
    ref = var.cloud-build-source-repo-revision
    # UNKNOWN, CLOUD_SOURCE_REPOSITORIES, GITHUB
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }
  git_file_source {
    path      = "cloudbuild/copy-image.yml"
    uri       = google_sourcerepo_repository.repo.url
    revision  = var.cloud-build-source-repo-revision
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }

  # https://cloud.google.com/build/docs/automate-builds-pubsub-events
  substitutions = {
    _LOCATION = google_artifact_registry_repository.docker.location
  }

  # If this is set on a build, it will become pending when it is run, 
  # and will need to be explicitly approved to start.
  approval_config {
    approval_required = true
  }
  depends_on = [null_resource.wait-for-docker-registry]
}