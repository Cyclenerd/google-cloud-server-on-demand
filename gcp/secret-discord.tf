# Create a secret version for Discord webhook URL
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret
resource "google_secret_manager_secret" "discord" {
  project   = google_project.my.project_id
  secret_id = "discord-webhook-url"

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
resource "null_resource" "wait-for-secret-discord" {
  provisioner "local-exec" {
    command = "sleep 120"
  }
  depends_on = [google_secret_manager_secret.discord]
}

# Allow service account for Cloud Function to send notifications to Discord to read secret
resource "google_secret_manager_secret_iam_member" "discord" {
  project   = google_project.my.project_id
  secret_id = google_secret_manager_secret.discord.secret_id
  # Secret Manager Secret Accessor
  # » Allows accessing the payload of secrets
  # » https://cloud.google.com/iam/docs/understanding-roles#secretmanager.secretAccessor
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.discord.email}"
  depends_on = [null_resource.wait-for-secret-discord, null_resource.wait-for-discord]
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version
resource "google_secret_manager_secret_version" "discord" {
  # Deploy only if Discord webhook URL is set
  count       = can(regex("discord(?:app)?\\.com\\/api\\/webhooks\\/\\d+/[^/?]+", var.discord-webhook-url)) ? 1 : 0
  secret      = google_secret_manager_secret.discord.id
  secret_data = var.discord-webhook-url
  depends_on  = [null_resource.wait-for-secret-discord, google_secret_manager_secret_iam_member.discord]
}