# Create a project-level logging sink for GCE shielded VM integrity activity
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink
resource "google_logging_project_sink" "logsink" {
  project     = google_project.my.project_id
  name        = "logsink-system-event-pubsub"
  description = "Log sink for Cloud Audit system events (Terraform managed)"
  # Can export to pubsub, cloud storage, or bigquery
  # "pubsub.googleapis.com/projects/[PROJECT_ID]/topics/[TOPIC_ID]"
  destination = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.logsink.name}"
  # Forward all cloudaudit.googleapis.com/system_event logs
  filter = "log_name=\"projects/${var.project}/logs/cloudaudit.googleapis.com%2Fsystem_event\""
  # Use a unique writer (creates a unique service account used for writing)
  # !!! Because our sink uses a unique_writer, we must grant that writer access to the topic. !!!
  # !!! We are doing this in pubsub-logsink.tf                                                !!!
  unique_writer_identity = true
}