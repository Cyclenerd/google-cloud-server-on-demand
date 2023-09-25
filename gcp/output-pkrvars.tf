# Store Packer variables in Google Storage bucket for later use with Cloud Build

# Copy source code as PKRVARs into bucket
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object
resource "google_storage_bucket_object" "pkrvars" {
  name    = "output.pkrvars.hcl"
  bucket  = google_storage_bucket.state.name
  content = <<-EOF
    # With Terraform generated variables file !!! Do not change manually !!!
    # Project
    project = "${google_project.my.project_id}"
    # Region
    region = "${var.region}"
    zone   = "${var.zone}"
    # Network
    subnetwork = "${google_compute_subnetwork.subnet.name}"
  EOF
}