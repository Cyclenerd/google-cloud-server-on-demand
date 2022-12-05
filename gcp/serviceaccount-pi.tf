# Create service account for Raspberry Pi
# Copy service account key to Raspberry Pi

# Create service account
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "pi" {
  project      = google_project.my.project_id
  account_id   = "raspberry-pi"
  display_name = "SA for Raspberry Pi"
  description  = "Service account for Raspberry Pi which triggers Cloud Build via Pub/Sub (Terraform managed)"
}

# Create private key
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_key
resource "google_service_account_key" "pi" {
  service_account_id = google_service_account.pi.name
}

# Sleep and wait for service account
# https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "wait-for-pi" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = [google_service_account.pi]
}