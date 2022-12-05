# Terraform versions
terraform {
  required_version = ">= 1.1.9"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.37.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.37.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2.0"
    }
  }
}