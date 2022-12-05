# Generate random UUID for bucket
resource "random_uuid" "state" {
}

# Create Google Storage bucket for Terraform state
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "state" {
  project  = google_project.my.project_id
  name     = "terraform-state-${random_uuid.state.id}"
  location = var.region

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = {
    "terraform" = "true"
  }
}