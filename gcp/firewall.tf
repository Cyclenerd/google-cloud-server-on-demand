# Create firewall rule for VPC
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
resource "google_compute_firewall" "default" {
  project   = google_project.my.project_id
  name      = "firewall-ingress-allow-default-${var.vpc-name}"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# Block egress SMTP traffic
resource "google_compute_firewall" "smtp" {
  project   = google_project.my.project_id
  name      = "firewall-egress-block-smtp-${var.vpc-name}"
  network   = google_compute_network.vpc.name
  direction = "EGRESS"
  deny {
    protocol = "tcp"
    ports    = ["25", "587", "465", "2525"]
  }
}