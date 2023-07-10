terraform {
  required_version = ">= 1.4.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.69.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
  }
}