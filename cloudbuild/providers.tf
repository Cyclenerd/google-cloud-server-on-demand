# Provider maintained by the Google Terraform Team at Google and the Terraform team at HashiCorp
# https://registry.terraform.io/providers/hashicorp/google/latest

provider "google" {
  project = var.project
  region  = var.region
  zone    = "${var.region}-${var.zone}"
}
