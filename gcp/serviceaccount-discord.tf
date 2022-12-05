# Create service account for Cloud Function to send notifications to Discord

# Create service account
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "discord" {
  project      = google_project.my.project_id
  account_id   = "discord"
  display_name = "SA for GCF to send notifications to Discord"
  description  = "Service account for Cloud Function to send notifications to Discord (Terraform managed)"
}

# Sleep and wait for service account
# https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "wait-for-discord" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = [google_service_account.discord]
}