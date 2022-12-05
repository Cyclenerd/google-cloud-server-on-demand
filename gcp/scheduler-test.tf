# Create Cloud Scheduler job
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job
resource "google_cloud_scheduler_job" "test" {
  project     = google_project.my.project_id
  name        = "job-test"
  region      = var.scheduler-region
  description = "Scheduler to test pipeline (Terraform managed)"
  # https://crontab.guru/#1_*/1_*_*_*
  schedule = "1 */1 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.destroy.id
    data       = base64encode("{\"test\":\"true\"}")
  }

  depends_on = [null_resource.wait-for-api]
}