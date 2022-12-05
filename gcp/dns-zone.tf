# Create DNS zone for GCE instances
resource "google_dns_managed_zone" "dns" {
  project     = google_project.my.project_id
  name        = "dns-${var.dns-zone}"
  description = "DNS zone for GCE instances (Terraform managed)"
  dns_name    = var.dns-domain
  depends_on  = [null_resource.wait-for-api]
}

# Create SPF record
resource "google_dns_record_set" "spf" {
  project      = google_project.my.project_id
  name         = var.dns-domain
  managed_zone = google_dns_managed_zone.dns.name
  type         = "TXT"
  ttl          = 21600
  rrdatas      = ["\"v=spf1 -all\""]
}
