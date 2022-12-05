# Create VPC for GCE instances
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "vpc" {
  project                 = google_project.my.project_id
  name                    = "vpc-${var.vpc-name}"
  description             = "Global VPC network for GCE instances (Terraform managed)"
  auto_create_subnetworks = false
  mtu                     = 1500
}

# Create subnetwork in region
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "subnet" {
  project = google_project.my.project_id
  name    = "subnet-${var.vpc-name}-${var.region}"
  # https://en.wikipedia.org/wiki/Carrier-grade_NAT
  ip_cidr_range = "100.64.0.0/10"
  region        = var.region
  network       = google_compute_network.vpc.id
}