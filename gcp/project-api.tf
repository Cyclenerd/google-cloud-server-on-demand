# Enable APIs
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
locals {
  google_apis = toset([
    # Compute Engine API
    "compute.googleapis.com",
    # Cloud DNS API
    "dns.googleapis.com",
    # Cloud Pub/Sub API
    "pubsub.googleapis.com",
    # Cloud Build API
    "cloudbuild.googleapis.com",
    # Cloud Source Repositories API
    "sourcerepo.googleapis.com",
    # Cloud Scheduler API
    "cloudscheduler.googleapis.com",
    # Service Usage API
    "serviceusage.googleapis.com",
    # Cloud Resource Manager API
    "cloudresourcemanager.googleapis.com",
    # Identity and Access Management (IAM) API
    "iam.googleapis.com",
    # Cloud Storage API
    "storage.googleapis.com",
    # Cloud Logging API
    "logging.googleapis.com",
    # Cloud Monitoring API
    "monitoring.googleapis.com",
    # Artifact Registry
    "artifactregistry.googleapis.com",
    # Cloud Function API
    "cloudfunctions.googleapis.com",
    # Secret Manager
    "secretmanager.googleapis.com",
  ])
}

resource "google_project_service" "google-apis" {
  for_each = local.google_apis
  service  = each.value
  project  = google_project.my.project_id
}

# Sleep and wait for APIs
resource "null_resource" "wait-for-api" {
  provisioner "local-exec" {
    # Wait 15 min
    command = "sleep 900"
  }
  depends_on = [google_project_service.google-apis]
}