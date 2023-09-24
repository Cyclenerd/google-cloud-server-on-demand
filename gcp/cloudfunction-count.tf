# Create Cloud Function for Cloud Build events (Pub/Sub)
# Function is used to count OS images

# Generate random UUID for bucket
resource "random_uuid" "cloudfunction-count" {
}

# Create bucket for Cloud Function source code
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "cloudfunction-count" {
  name                        = "cloudfunction-count-${random_uuid.cloudfunction-count.id}"
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
data "archive_file" "cloudfunction-count" {
  type = "zip"
  source {
    content  = file("${path.module}/cloudfunction-count/main.py")
    filename = "main.py"
  }
  source {
    content  = file("${path.module}/cloudfunction-count/requirements.txt")
    filename = "requirements.txt"
  }
  output_path = "${path.module}/cloudfunction-count.zip"
}

# Copy source code as ZIP into bucket
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object
resource "google_storage_bucket_object" "cloudfunction-count" {
  name   = "cloudbuild-count-${data.archive_file.cloudfunction-count.output_md5}.zip"
  bucket = google_storage_bucket.cloudfunction-count.name
  source = data.archive_file.cloudfunction-count.output_path
}

# Generate random id for GCF name
resource "random_id" "cloudfunction-count" {
  byte_length = 8
}

# Create Cloud Function with Pub/Sub event trigger
# Default Cloud Function service account is used
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function
resource "google_cloudfunctions_function" "cloudfunction-count" {
  name        = "cloudbuild-count-${random_id.cloudfunction-count.hex}"
  description = "Function to count OS images"
  project     = google_project.my.project_id
  region      = var.region
  # Service account to run the function with
  service_account_email = google_service_account.count.email
  # Use Artifact Registry repository for function docker image
  docker_repository = google_artifact_registry_repository.docker.id
  # Runtime ID
  # https://cloud.google.com/functions/docs/concepts/exec#runtimes
  runtime               = "python311"
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.cloudfunction-count.name
  source_archive_object = google_storage_bucket_object.cloudfunction-count.name
  entry_point           = "count"
  timeout               = 120
  min_instances         = 0
  max_instances         = 20
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.create.name
    failure_policy {
      retry = false
    }
  }
  labels = {
    terraform = "true"
  }
  environment_variables = {
    MY_GOOGLE_CLOUD_PROJECT = google_project.my.project_id
    MY_GOOGLE_CLOUD_REGION  = var.region
  }
  depends_on = [
    null_resource.wait-for-docker-registry,
    google_project_iam_member.count-metric-writer
  ]
}