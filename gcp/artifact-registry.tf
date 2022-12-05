# Create Artifact Registry repository
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository
resource "google_artifact_registry_repository" "docker" {
  project       = google_project.my.project_id
  location      = var.region
  repository_id = "cointainer"
  description   = "Docker cointainer repository"
  format        = "DOCKER"
  depends_on    = [null_resource.wait-for-api]
}


# Sleep and wait for Artifact Registry repository
# https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "wait-for-docker-registry" {
  provisioner "local-exec" {
    # Wait 5 min
    command = "sleep 300"
  }
  depends_on = [google_artifact_registry_repository.docker]
}