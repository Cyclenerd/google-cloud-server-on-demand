# Terraform versions
terraform {
  required_version = ">= 1.4.4"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.69.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.69.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2.0"
    }
  }
}