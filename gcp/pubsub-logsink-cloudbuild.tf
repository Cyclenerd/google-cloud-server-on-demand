# Create Pub/Sub topic for Cloud Build log sink
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic
resource "google_pubsub_topic" "logsink-cloudbuild" {
  project = google_project.my.project_id
  name    = "pubsub-cloudbuild-logsink"
  message_storage_policy {
    allowed_persistence_regions = ["${var.region}"]
  }
  labels = {
    "terraform" = "true"
  }
}

# Create Pub/Sub subscription to have the possibility to read (pull) the messages via the console (dashboard)
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription
resource "google_pubsub_subscription" "logsink-cloudbuild" {
  project = google_project.my.project_id
  name    = "pull-cloudbuild-logsink"
  topic   = google_pubsub_topic.logsink-cloudbuild.name
  labels = {
    "terraform" = "true"
  }
}

# Allow Logsink service account to publish messages to topic

# Updates the IAM policy to grant a role to service account. Other members for the role for the topic are preserved.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam#google_pubsub_topic_iam_member
resource "google_pubsub_topic_iam_member" "logsink-cloudbuild" {
  project = google_project.my.project_id
  topic   = google_pubsub_topic.logsink-cloudbuild.name
  # https://cloud.google.com/iam/docs/understanding-roles#pub-sub-roles
  role   = "roles/pubsub.publisher"
  member = google_logging_project_sink.logsink-cloudbuild.writer_identity
}

# Allow service account for Cloud Function to send notifications to Discord to read topic
resource "google_pubsub_topic_iam_member" "logsink-cloudfunction-cloudbuild" {
  project = google_project.my.project_id
  topic   = google_pubsub_topic.logsink-cloudbuild.name
  # https://cloud.google.com/iam/docs/understanding-roles#pub-sub-roles
  role       = "roles/pubsub.subscriber"
  member     = "serviceAccount:${google_service_account.discord.email}"
  depends_on = [null_resource.wait-for-discord]
}