# Create project
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project
resource "google_project" "my" {
  name       = var.project
  project_id = var.project
  folder_id  = var.folder
  # Terraform must have at minimum Billing Account User privileges (roles/billing.user) on the billing account.
  billing_account = var.billing_account
  # Constraint compute.skipDefaultNetworkCreation is also used to remove the default network
  auto_create_network = "false"
  labels = {
    "terraform" = "true"
  }
}