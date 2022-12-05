# Create Google Cloud Source repository
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sourcerepo_repository
resource "google_sourcerepo_repository" "repo" {
  project    = google_project.my.project_id
  name       = "repo-${var.cloud-build-source-repo}"
  depends_on = [null_resource.wait-for-api]
}