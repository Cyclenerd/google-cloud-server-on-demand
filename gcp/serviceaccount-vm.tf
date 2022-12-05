# Create service account for VM
# One service account for all VMs to avoid reaching the 300 service account quota.

# Create service account
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "vm" {
  project      = google_project.my.project_id
  account_id   = "compute"
  display_name = "SA for Compute Engine instances"
  description  = "Service account for Google Compute Engine instances (Terraform managed)"
}

# Sleep and wait for service account
# https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "wait-for-vm" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = [google_service_account.vm]
}

# Updates the IAM policy to grant a role to service account. Other members for the role for the project are preserved.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "log" {
  project    = google_project.my.project_id
  role       = "roles/logging.logWriter"
  member     = "serviceAccount:${google_service_account.vm.email}"
  depends_on = [null_resource.wait-for-vm]
}

resource "google_project_iam_member" "metric" {
  project    = google_project.my.project_id
  role       = "roles/monitoring.metricWriter"
  member     = "serviceAccount:${google_service_account.vm.email}"
  depends_on = [google_project_iam_member.log]
}