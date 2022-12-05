# Project ID
output "project" {
  description = "Project ID"
  value       = google_project.my.project_id
}

# Google Cloud region
output "region" {
  description = "Google Cloud region"
  value       = var.region
}

# Google Cloud zone
output "zone" {
  description = "Google Cloud zone in region"
  value       = var.zone
}

# Google Cloud region for Google Cloud scheduler
output "scheduler-region" {
  description = "Cloud scheduler region"
  value       = var.scheduler-region
}

# Minutes for Cloud Scheduler destroy trigger
output "expires" {
  description = "Duration (minutes) until the VM is destroyed"
  value       = var.expires
}

# Global VPC network name
output "network" {
  description = "Global VPC network name"
  value       = google_compute_network.vpc.name
}

# Local subnet name in region
output "subnetwork" {
  description = "Local subnet name in region"
  value       = google_compute_subnetwork.subnet.name
}

# Pub/Sub topic to destroy build
output "pub-sub-destroy-topic" {
  description = "Pub/sub topic to destroy GCE instance build after N hours"
  value       = google_pubsub_topic.destroy.id
}

# DNS zone name
output "dns-zone" {
  description = "DNS zone name"
  value       = google_dns_managed_zone.dns.name
}

# DNS domain
output "dns-domain" {
  description = "DNS domain"
  value       = google_dns_managed_zone.dns.dns_name
}

# Service account for GCE
output "sa-compute" {
  description = "SA for Compute Engine instances"
  value       = google_service_account.vm.email
}
