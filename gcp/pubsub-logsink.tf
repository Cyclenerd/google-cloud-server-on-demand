# Create Pub/Sub topic for log sink
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic
resource "google_pubsub_topic" "logsink" {
  project = google_project.my.project_id
  name    = "pubsub-system-event-logsink"
  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
  labels = {
    "terraform" = "true"
  }
}

# Create Pub/Sub subscription to have the possibility to read (pull) the messages via the console (dashboard)
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription
resource "google_pubsub_subscription" "logsink" {
  project = google_project.my.project_id
  name    = "pull-system-event-logsink"
  topic   = google_pubsub_topic.logsink.name
  labels = {
    "terraform" = "true"
  }
}

# Allow Logsink service account to publish messages to topic

# Updates the IAM policy to grant a role to service account. Other members for the role for the topic are preserved.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam#google_pubsub_topic_iam_member
resource "google_pubsub_topic_iam_member" "logsink" {
  project = google_project.my.project_id
  topic   = google_pubsub_topic.logsink.name
  # https://cloud.google.com/iam/docs/understanding-roles#pub-sub-roles
  role   = "roles/pubsub.publisher"
  member = google_logging_project_sink.logsink.writer_identity
}