# Create monitoring metric to count operating system images

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_metric_descriptor
resource "google_monitoring_metric_descriptor" "count" {
  project      = google_project.my.project_id
  description  = "Deployed operating system images"
  display_name = "metric-compute-os-images"
  type         = "custom.googleapis.com/compute/os/images"
  metric_kind  = "GAUGE"
  value_type   = "DOUBLE"
  labels {
    key         = "image"
    value_type  = "STRING"
    description = "GCE operating system images"
  }
  depends_on = [null_resource.wait-for-api]
}