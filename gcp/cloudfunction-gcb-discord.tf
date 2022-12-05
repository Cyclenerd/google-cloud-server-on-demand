# Create Cloud Function for Cloud Build events (Pub/Sub)
# Function is used to send notification to Discord if Cloud Build job failed

# Generate random UUID for bucket
resource "random_uuid" "cloudfunction-cloudbuild" {
}

# Create bucket for Cloud Function source code
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "cloudfunction-cloudbuild" {
  name                        = "cloudfunction-source-${random_uuid.cloudfunction-cloudbuild.id}"
  project                     = google_project.my.project_id
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  labels = {
    "terraform" = "true"
  }
}

# Create ZIP with source code for GCF
# https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file
data "archive_file" "cloudfunction-cloudbuild" {
  type = "zip"
  source {
    content  = file("${path.module}/cloudfunction-gcb-discord/main.py")
    filename = "main.py"
  }
  source {
    content  = file("${path.module}/cloudfunction-gcb-discord/requirements.txt")
    filename = "requirements.txt"
  }
  output_path = "${path.module}/cloudfunction-gcb-discord.zip"
}

# Copy source code as ZIP into bucket
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object
resource "google_storage_bucket_object" "cloudfunction-cloudbuild" {
  name   = "cloudbuild-discord-${data.archive_file.cloudfunction-cloudbuild.output_md5}.zip"
  bucket = google_storage_bucket.cloudfunction-cloudbuild.name
  source = data.archive_file.cloudfunction-cloudbuild.output_path
}

# Generate random id for GCF name
resource "random_id" "cloudfunction-cloudbuild" {
  byte_length = 8
}

# Create Cloud Function with Pub/Sub event trigger
# Default Cloud Function service account is used
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function
resource "google_cloudfunctions_function" "cloudfunction-cloudbuild" {
  # Deploy only if Discord webhook URL is set
  #count = "${var.discord-webhook-url != "" ? 1 : 0}"
  count = can(regex("discord(?:app)?\\.com\\/api\\/webhooks\\/\\d+/[^/?]+", var.discord-webhook-url)) ? 1 : 0

  name        = "cloudbuild-discord-${random_id.cloudfunction-cloudbuild.hex}"
  description = "Function to send notifications to Discord if Cloud Build job failed"
  project     = google_project.my.project_id
  region      = var.region
  # Service account to run the function with
  service_account_email = google_service_account.discord.email
  # Use Artifact Registry repository for function docker image
  docker_repository = google_artifact_registry_repository.docker.id
  # Runtime ID
  # https://cloud.google.com/functions/docs/concepts/exec#runtimes
  runtime               = "python39"
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.cloudfunction-cloudbuild.name
  source_archive_object = google_storage_bucket_object.cloudfunction-cloudbuild.name
  entry_point           = "discord"
  timeout               = 120
  min_instances         = 0
  max_instances         = 100
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.logsink-cloudbuild.name
    failure_policy {
      retry = false
    }
  }
  labels = {
    terraform = "true"
  }
  /*
  environment_variables = {
    DISCORD_WEBHOOK_URL = var.discord-webhook-url
  }
  */
  secret_environment_variables {
    key        = "DISCORD_WEBHOOK_URL"
    project_id = google_project.my.number
    secret     = google_secret_manager_secret.discord.secret_id
    version    = "latest"
  }
  depends_on = [null_resource.wait-for-docker-registry, google_secret_manager_secret_version.discord]
}