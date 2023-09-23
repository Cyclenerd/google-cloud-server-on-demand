# Create Cloud Function for Cloud Build events (Pub/Sub)
# Function is used to monitor the CPU temperature of the Raspberry Pi

# Generate random UUID for bucket
resource "random_uuid" "cloudfunction-temp-monitoring" {
}

# Create bucket for Cloud Function source code
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "cloudfunction-temp-monitoring" {
  name                        = "cloudfunction-temp-moni-${random_uuid.cloudfunction-temp-monitoring.id}"
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
data "archive_file" "cloudfunction-temp-monitoring" {
  type = "zip"
  source {
    content  = file("${path.module}/cloudfunction-temp-monitoring/main.py")
    filename = "main.py"
  }
  source {
    content  = file("${path.module}/cloudfunction-temp-monitoring/requirements.txt")
    filename = "requirements.txt"
  }
  output_path = "${path.module}/cloudfunction-temp-monitoring.zip"
}

# Copy source code as ZIP into bucket
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object
resource "google_storage_bucket_object" "cloudfunction-temp-monitoring" {
  name   = "cloudbuild-temp-monitoring-${data.archive_file.cloudfunction-temp-monitoring.output_md5}.zip"
  bucket = google_storage_bucket.cloudfunction-temp-monitoring.name
  source = data.archive_file.cloudfunction-temp-monitoring.output_path
}

# Generate random id for GCF name
resource "random_id" "cloudfunction-temp-monitoring" {
  byte_length = 8
}

# Create Cloud Function with Pub/Sub event trigger
# Default Cloud Function service account is used
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function
resource "google_cloudfunctions_function" "cloudfunction-temp-monitoring" {
  name        = "cloudbuild-temp-monitoring-${random_id.cloudfunction-temp-monitoring.hex}"
  description = "Function to monitor the CPU temperature of the Raspberry Pi"
  project     = google_project.my.project_id
  region      = var.region
  # Service account to run the function with
  service_account_email = google_service_account.temp-monitoring.email
  # Use Artifact Registry repository for function docker image
  docker_repository = google_artifact_registry_repository.docker.id
  # Runtime ID
  # https://cloud.google.com/functions/docs/concepts/exec#runtimes
  runtime               = "python311"
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.cloudfunction-temp-monitoring.name
  source_archive_object = google_storage_bucket_object.cloudfunction-temp-monitoring.name
  entry_point           = "temp"
  timeout               = 120
  min_instances         = 0
  max_instances         = 2
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.temp.name
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
    null_resource.wait-for-temp-monitoring,
    google_monitoring_metric_descriptor.temp-monitoring
  ]
}