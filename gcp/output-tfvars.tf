# Store Terraform variables in Google Storage bucket for later use with Cloud Build

# Copy source code as TFVARs into bucket
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object
resource "google_storage_bucket_object" "tfvars" {
  name    = "output.tfvars"
  bucket  = google_storage_bucket.state.name
  content = <<-EOF
    # With Terraform generated variables file !!! Do not change manually !!!
    # Project
    project               = "${google_project.my.project_id}"
    # Region
    region                = "${var.region}"
    zone                  = "${var.zone}"
    scheduler-region      = "${var.scheduler-region}"
    # Network
    network               = "${google_compute_network.vpc.name}"
    subnetwork            = "${google_compute_subnetwork.subnet.name}"
    # Service account
    sa-compute            = "${google_service_account.vm.email}"
    # DNS
    dns-domain            = "${google_dns_managed_zone.dns.dns_name}"
    dns-zone              = "${google_dns_managed_zone.dns.name}"
    # Pub/Sub
    pub-sub-destroy-topic = "${google_pubsub_topic.destroy.id}"
    # Cloud Scheduler
    expires               = "${var.expires}"
  EOF
}