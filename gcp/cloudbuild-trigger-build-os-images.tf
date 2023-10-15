# Create Cloud Build trigger to build custom OS images
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger
resource "google_cloudbuild_trigger" "build-os-images" {
  project     = google_project.my.project_id
  name        = "build-os-images"
  description = "Push to branch trigger to build custom OS images (Terraform managed)"

  included_files = ["cloudbuild/linux/**"]
  trigger_template {
    project_id  = google_project.my.project_id
    repo_name   = google_sourcerepo_repository.repo.name
    branch_name = var.cloud-build-source-trigger-branch
  }

  // Google Cloud Source repository
  source_to_build {
    uri = google_sourcerepo_repository.repo.url
    ref = var.cloud-build-source-repo-revision
    # UNKNOWN, CLOUD_SOURCE_REPOSITORIES, GITHUB
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }
  git_file_source {
    path      = "cloudbuild/linux/build.yml"
    uri       = google_sourcerepo_repository.repo.url
    revision  = var.cloud-build-source-repo-revision
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }

  # https://cloud.google.com/build/docs/automate-builds-pubsub-events
  substitutions = {
    _STATE_BUCKET = google_storage_bucket.state.name
  }
}