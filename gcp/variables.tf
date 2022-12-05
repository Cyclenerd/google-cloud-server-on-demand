variable "project" {
  type        = string
  nullable    = false
  description = "Google Cloud project ID. Changing this forces a new project to be created."
  # https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin
  validation {
    # Must be 6 to 30 characters in length.
    # Can only contain lowercase letters, numbers, and hyphens.
    # Must start with a letter.
    # Cannot end with a hyphen.
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project))
    error_message = "Invalid project ID!"
  }
}

variable "billing_account" {
  type        = string
  nullable    = false
  description = "The alphanumeric ID of the billing account this project belongs to."
  validation {
    # https://www.terraform.io/language/functions/regex
    condition     = can(regex("^[0-9A-Z]{6}-[0-9A-Z]{6}-[0-9A-Z]{6}$", var.billing_account))
    error_message = "Specify billing account as alphanumeric text!"
  }
}

variable "folder" {
  type        = string
  nullable    = false
  description = "The numeric ID of the folder this project should be created under."
  validation {
    # https://cloud.google.com/resource-manager/reference/rest/v3/folders
    condition     = can(regex("^[0-9]{1,32}$", var.folder))
    error_message = "Invalid folder ID!"
  }
}

variable "dns-domain" {
  type        = string
  nullable    = false
  description = "Google Cloud DNS domain name suffix for managed zone (Example: myzone.example.com.)"
  validation {
    condition     = can(regex("^[a-z0-9-\\.]{1,61}\\.[a-z]{2,}\\.$", var.dns-domain))
    error_message = "Invalid domain! (Don't forget the name field must end with trailing dot)"
  }
}

variable "region" {
  type        = string
  nullable    = false
  description = "Google Cloud region"
  # Belgium : https://gcloud-compute.com/europe-west1.html
  default = "europe-west1"
}

variable "scheduler-region" {
  type        = string
  nullable    = false
  description = "Google Cloud region for Google Cloud scheduler"
  default     = "europe-west1"
}

# Used in https://www.terraform.io/language/functions/timeadd
variable "expires" {
  type        = string
  nullable    = false
  description = "Duration (minutes) until the VM is destroyed"
  default     = "180"
}

variable "zone" {
  type        = string
  nullable    = false
  description = "Google Cloud zone [a,b,c,d,e] in region"
  default     = "b"
}

variable "vpc-name" {
  type        = string
  nullable    = false
  description = "Google Cloud VPC network name"
  default     = "soda"
}

variable "dns-zone" {
  type        = string
  nullable    = false
  description = "Google Cloud DNS managed zone name"
  default     = "soda"
}

variable "cloud-build-source-repo" {
  type        = string
  nullable    = false
  description = "Google Cloud Source repository for Cloud Build tools and scripts"
  default     = "soda"
}

variable "cloud-build-source-repo-revision" {
  type        = string
  nullable    = false
  description = "Google Cloud Source repository revision for Cloud Build tools and scripts"
  default     = "refs/heads/master"
}

variable "discord-webhook-url" {
  type        = string
  nullable    = false
  description = "Your Discord webhook URL (example: https://discord.com/api/webhooks/[WEBHOOK-ID]/[WEBHOOK-TOKEN])"
  default     = ""
}