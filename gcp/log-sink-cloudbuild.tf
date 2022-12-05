# Create a project-level logging sink for Cloud Build logs
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink
resource "google_logging_project_sink" "logsink-cloudbuild" {
  project     = google_project.my.project_id
  name        = "logsink-cloudbuild-pubsub"
  description = "Log sink for Cloud Build errors and timeouts (Terraform managed)"
  # Can export to pubsub, cloud storage, or bigquery
  # "pubsub.googleapis.com/projects/[PROJECT_ID]/topics/[TOPIC_ID]"
  destination = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.logsink-cloudbuild.name}"
  # Forward filtered Cloud Build logs
  filter = "log_name=\"projects/${var.project}/logs/cloudbuild\" AND (textPayload=\"TIMEOUT\" OR textPayload=\"ERROR\")"
  # Use a unique writer (creates a unique service account used for writing)
  # !!! Because our sink uses a unique_writer, we must grant that writer access to the topic. !!!
  # !!! We are doing this in pubsub-logsink-cloudbuild.tf                                     !!!
  unique_writer_identity = true
}