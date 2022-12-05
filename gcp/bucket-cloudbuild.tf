# Generate random UUID for bucket
resource "random_uuid" "source" {
}

# Create Google Storage bucket for Cloud Build source
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "source" {
  project  = google_project.my.project_id
  name     = "cloud-build-source-${random_uuid.source.id}"
  location = var.region

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    "terraform" = "true"
  }
}