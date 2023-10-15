# Create Cloud Function for Cloud Build events (Pub/Sub)
# Function is used to send notification to Pushover if Cloud Build job failed

# Generate random UUID for bucket
resource "random_uuid" "cloudfunction-pushover" {
}

# Create bucket for Cloud Function source code
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "cloudfunction-pushover" {
  name                        = "cloudfunction-pushover-${random_uuid.cloudfunction-pushover.id}"
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
data "archive_file" "cloudfunction-pushover" {
  type = "zip"
  source {
    content  = file("${path.module}/cloudfunction-gcb-pushover/main.py")
    filename = "main.py"
  }
  source {
    content  = file("${path.module}/cloudfunction-gcb-pushover/requirements.txt")
    filename = "requirements.txt"
  }
  output_path = "${path.module}/cloudfunction-gcb-pushover.zip"
}

# Copy source code as ZIP into bucket
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object
resource "google_storage_bucket_object" "cloudfunction-pushover" {
  name   = "cloudbuild-pushover-${data.archive_file.cloudfunction-pushover.output_md5}.zip"
  bucket = google_storage_bucket.cloudfunction-pushover.name
  source = data.archive_file.cloudfunction-pushover.output_path
}

# Generate random id for GCF name
resource "random_id" "cloudfunction-pushover" {
  byte_length = 8
}

# Create Cloud Function with Pub/Sub event trigger
# Default Cloud Function service account is used
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function
resource "google_cloudfunctions_function" "cloudfunction-pushover" {
  # Deploy only if Pushover API token is set
  count       = var.pushover-api-token != "" ? 1 : 0
  name        = "cloudbuild-pushover-${random_id.cloudfunction-pushover.hex}"
  description = "Function to send notifications to Pushover if Cloud Build job failed"
  project     = google_project.my.project_id
  region      = var.region
  # Service account to run the function with
  service_account_email = google_service_account.pushover.email
  # Use Artifact Registry repository for function docker image
  docker_repository = google_artifact_registry_repository.docker.id
  # Runtime ID
  # https://cloud.google.com/functions/docs/concepts/exec#runtimes
  runtime               = "python311"
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.cloudfunction-pushover.name
  source_archive_object = google_storage_bucket_object.cloudfunction-pushover.name
  entry_point           = "pushover"
  timeout               = 120
  min_instances         = 0
  max_instances         = 2
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
  secret_environment_variables {
    key        = "PUSHOVER_USER_KEY"
    project_id = var.project
    secret     = google_secret_manager_secret.pushover-user-key.secret_id
    version    = "latest"
  }
  secret_environment_variables {
    key        = "PUSHOVER_API_TOKEN"
    project_id = var.project
    secret     = google_secret_manager_secret.pushover-api-token.secret_id
    version    = "latest"
  }
  depends_on = [
    null_resource.wait-for-docker-registry,
    google_secret_manager_secret_version.pushover-user-key,
    google_secret_manager_secret_version.pushover-api-token
  ]
}