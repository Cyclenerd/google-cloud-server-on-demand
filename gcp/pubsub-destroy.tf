# Create Pub/Sub topic to destroy previous build
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic
resource "google_pubsub_topic" "destroy" {
  project = google_project.my.project_id
  name    = "pubsub-destroy"
  message_storage_policy {
    allowed_persistence_regions = ["${var.region}"]
  }
  labels = {
    "terraform" = "true"
  }
}

# Create Pub/Sub subscription to have the possibility to read (pull) the messages via the console (dashboard)
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription
resource "google_pubsub_subscription" "destroy" {
  project = google_project.my.project_id
  name    = "pull-destroy"
  topic   = google_pubsub_topic.destroy.name
  labels = {
    "terraform" = "true"
  }
}

# Allow Cloud Scheduler service account to publish messages to topic

# Updates the IAM policy to grant a role to service account. Other members for the role for the topic are preserved.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam#google_pubsub_topic_iam_member
resource "google_pubsub_topic_iam_member" "destroy" {
  project = google_project.my.project_id
  topic   = google_pubsub_topic.destroy.name
  # https://cloud.google.com/iam/docs/understanding-roles#pub-sub-roles
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_project_service_identity.scheduler.email}"
}