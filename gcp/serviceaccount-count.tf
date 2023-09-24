# Create service account for Cloud Function to count OS images

# Create service account
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "count" {
  project      = google_project.my.project_id
  account_id   = "count-os-images"
  display_name = "SA for GCF to count OS images"
  description  = "Service account for Cloud Function to count OS images (Terraform managed)"
  depends_on   = [google_project_organization_policy.iam-disableServiceAccountCreation]
}

# Sleep and wait for service account
# https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "wait-for-count" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = [google_service_account.count]
}

# Updates the IAM policy to grant a role to service account. Other members for the role for the topic are preserved.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member
resource "google_project_iam_member" "count-metric-writer" {
  project = google_project.my.project_id
  # https://cloud.google.com/iam/docs/understanding-roles#monitoring.metricWriter
  role       = "roles/monitoring.metricWriter"
  member     = "serviceAccount:${google_service_account.count.email}"
  depends_on = [null_resource.wait-for-count]
}