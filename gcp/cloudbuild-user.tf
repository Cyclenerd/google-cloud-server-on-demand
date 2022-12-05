# Get email of default Cloud Build service account
resource "google_project_service_identity" "cloudbuild" {
  provider   = google-beta
  project    = google_project.my.project_id
  service    = "cloudbuild.googleapis.com"
  depends_on = [null_resource.wait-for-api]
}

###############################################################################
# SET ROLES
# https://cloud.google.com/iam/docs/understanding-roles
###############################################################################

# Cloud Build Service Account
# https://cloud.google.com/iam/docs/understanding-roles#cloud-build-roles
resource "google_project_iam_member" "cloudbuild-builder" {
  project = google_project.my.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
}

# Compute Admin
# https://cloud.google.com/iam/docs/understanding-roles#compute-engine-roles
resource "google_project_iam_member" "cloudbuild-compute-admin" {
  project = google_project.my.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
}

# DNS Administrator
# https://cloud.google.com/iam/docs/understanding-roles#dns-roles
resource "google_project_iam_member" "cloudbuild-dns-admin" {
  project = google_project.my.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
}

# Project IAM Admin
# https://cloud.google.com/iam/docs/understanding-roles#resource-manager-roles
resource "google_project_iam_member" "cloudbuild-iam-admin" {
  project = google_project.my.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
}

# Service Account Admin
# https://cloud.google.com/iam/docs/understanding-roles#service-accounts-roles
resource "google_project_iam_member" "cloudbuild-sa-admin" {
  project = google_project.my.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
}

# Service Account User
# https://cloud.google.com/iam/docs/understanding-roles#service-accounts-roles
resource "google_project_iam_member" "cloudbuild-sa-user" {
  project = google_project.my.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
}

# Pub/Sub Admin
# https://cloud.google.com/iam/docs/understanding-roles#pub-sub-roles
resource "google_project_iam_member" "cloudbuild-pubsub-admin" {
  project = google_project.my.project_id
  role    = "roles/pubsub.admin"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
}

# Source Repository Administrator
# https://cloud.google.com/iam/docs/understanding-roles#source-roles
resource "google_project_iam_member" "cloudbuild-source-admin" {
  project = google_project.my.project_id
  role    = "roles/source.admin"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
}

# Cloud Scheduler Admin
# https://cloud.google.com/iam/docs/understanding-roles#cloud-scheduler-roles
resource "google_project_iam_member" "cloudbuild-scheduler-admin" {
  project = google_project.my.project_id
  role    = "roles/cloudscheduler.admin"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
}

# Logs Configuration Writer
#   Provides permissions to read and write the configurations
#   of logs-based metrics and sinks for exporting logs.
# https://cloud.google.com/iam/docs/understanding-roles#logging-roles
resource "google_project_iam_member" "cloudbuild-logging-writer" {
  project = google_project.my.project_id
  role    = "roles/logging.configWriter"
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
}