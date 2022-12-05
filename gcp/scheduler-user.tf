# Get email of default Cloud Scheduler service account
resource "google_project_service_identity" "scheduler" {
  provider   = google-beta
  project    = google_project.my.project_id
  service    = "cloudscheduler.googleapis.com"
  depends_on = [null_resource.wait-for-api]
}