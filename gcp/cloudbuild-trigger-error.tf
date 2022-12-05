# Create Cloud Build trigger to simulate error
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger
resource "google_cloudbuild_trigger" "error" {
  project     = google_project.my.project_id
  name        = "simulate-error"
  description = "Trigger to simulate Cloud Build job error (Terraform managed)"

  // Google Cloud Source repository
  source_to_build {
    uri = google_sourcerepo_repository.repo.url
    ref = var.cloud-build-source-repo-revision
    # UNKNOWN, CLOUD_SOURCE_REPOSITORIES, GITHUB
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }
  git_file_source {
    path      = "cloudbuild/simulate-error.yml"
    uri       = google_sourcerepo_repository.repo.url
    revision  = var.cloud-build-source-repo-revision
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }

  # If this is set on a build, it will become pending when it is run, 
  # and will need to be explicitly approved to start.
  approval_config {
    approval_required = true
  }
}