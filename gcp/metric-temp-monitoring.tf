# Create monitoring metric for CPU temperature of the Raspberry Pi

resource "google_monitoring_metric_descriptor" "temp-monitoring" {
  project      = google_project.my.project_id
  description  = "CPU temp. of the Raspberry Pi"
  display_name = "metric-raspi-cpu-temp"
  type         = "custom.googleapis.com/raspi/cpu/temp"
  metric_kind  = "GAUGE"
  value_type   = "DOUBLE"
  depends_on   = [null_resource.wait-for-api]
}