# Create a secret version for Pushover user key
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret
resource "google_secret_manager_secret" "pushover-user-key" {
  project   = var.project
  secret_id = "pushover-user-key"
  labels = {
    terraform = "true"
  }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [null_resource.wait-for-api]
}

# Create a secret version for Pushover application's API token/key
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret
resource "google_secret_manager_secret" "pushover-api-token" {
  project   = var.project
  secret_id = "pushover-api-token"
  labels = {
    terraform = "true"
  }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [null_resource.wait-for-api]
}

# Sleep and wait for Secret Manager
# https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "wait-for-secret-pushover" {
  provisioner "local-exec" {
    command = "sleep 120"
  }
  depends_on = [
    google_secret_manager_secret.pushover-user-key,
    google_secret_manager_secret.pushover-api-token
  ]
}

# Allow service account for Cloud Function to send notifications to Pushover to read secret
resource "google_secret_manager_secret_iam_member" "pushover-user-key" {
  project    = var.project
  secret_id  = google_secret_manager_secret.pushover-user-key.secret_id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.pushover.email}"
  depends_on = [null_resource.wait-for-secret-pushover, null_resource.wait-for-pushover]
}
resource "google_secret_manager_secret_iam_member" "pushover-api-token" {
  project    = var.project
  secret_id  = google_secret_manager_secret.pushover-api-token.secret_id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.pushover.email}"
  depends_on = [null_resource.wait-for-secret-pushover, null_resource.wait-for-pushover]
}

# Add secrets
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version
resource "google_secret_manager_secret_version" "pushover-user-key" {
  # Deploy only if Pushover user key is set
  count       = var.pushover-user-key != "" ? 1 : 0
  secret      = google_secret_manager_secret.pushover-user-key.id
  secret_data = var.pushover-user-key
  depends_on = [
    null_resource.wait-for-secret-pushover,
    google_secret_manager_secret_iam_member.pushover-user-key
  ]
}
resource "google_secret_manager_secret_version" "pushover-api-token" {
  # Deploy only if Pushover API token is set
  count       = var.pushover-api-token != "" ? 1 : 0
  secret      = google_secret_manager_secret.pushover-api-token.id
  secret_data = var.pushover-api-token
  depends_on = [
    null_resource.wait-for-secret-pushover,
    google_secret_manager_secret_iam_member.pushover-api-token
  ]
}