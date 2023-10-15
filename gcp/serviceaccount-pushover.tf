# Create service account for Cloud Function to send notifications to Pushover

# Create service account
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "pushover" {
  project      = google_project.my.project_id
  account_id   = "pushover"
  display_name = "SA for GCF to send notifications to Pushover"
  description  = "Service account for Cloud Function to send notifications to Pushover (Terraform managed)"
  depends_on   = [google_project_organization_policy.iam-disableServiceAccountCreation]
}

# Sleep and wait for service account
# https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "wait-for-pushover" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = [google_service_account.pushover]
}