# Create service account for Cloud Function to monitor the CPU temperature of the Raspberry Pi

# Create service account
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "temp-monitoring" {
  project      = google_project.my.project_id
  account_id   = "temp-monitoring"
  display_name = "SA for GCF to monitor the CPU temp. of the Raspberry Pi"
  description  = "Service account for Cloud Function to monitor the CPU temperature of the Raspberry Pi (Terraform managed)"
  depends_on   = [google_project_organization_policy.iam-disableServiceAccountCreation]
}

# Sleep and wait for service account
# https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "wait-for-temp-monitoring" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = [google_service_account.temp-monitoring]
}

# Updates the IAM policy to grant a role to service account. Other members for the role for the topic are preserved.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member
resource "google_project_iam_member" "pi-temp-metric-writer" {
  project = google_project.my.project_id
  # https://cloud.google.com/iam/docs/understanding-roles#monitoring.metricWriter
  role       = "roles/monitoring.metricWriter"
  member     = "serviceAccount:${google_service_account.temp-monitoring.email}"
  depends_on = [null_resource.wait-for-temp-monitoring]
}