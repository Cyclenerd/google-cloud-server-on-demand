# Enforce boolean policies on project
# https://cloud.google.com/architecture/security-foundations/using-example-terraform#organization-policy-setup
# https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints
locals {
  google_boolean_organization_policies = toset([
    # COMPUTE
    # Disables hardware-accelerated nested virtualization for all Compute Engine VMs
    "compute.disableNestedVirtualization",
    # Disables serial port access to Compute Engine VMs
    "compute.disableSerialPortAccess",
    # Disables Compute Engine API access to the guest attributes of Compute Engine VMs
    "compute.disableGuestAttributesAccess",
    # Skip the creation of the default network and related resources during Google Cloud project resource creation
    "compute.skipDefaultNetworkCreation",
    # IAM
    # Disable Service Account Key Upload
    "constraints/iam.disableServiceAccountKeyUpload",
    # Disable Automatic IAM Grants (Editor role) for Default Service Accounts
    "constraints/iam.automaticIamGrantsForDefaultServiceAccounts",
    # STORAGE
    # Requires buckets to use uniform IAM-based bucket-level access
    "constraints/storage.uniformBucketLevelAccess",
    # Enforce Public Access Prevention on Google Storage Buckets
    "constraints/storage.publicAccessPrevention",
  ])
}

resource "google_project_organization_policy" "organization-policies" {
  for_each   = local.google_boolean_organization_policies
  project    = google_project.my.project_id
  constraint = each.value
  boolean_policy {
    enforced = true
  }
}

# Disable Policy for Require OS Login
resource "google_project_organization_policy" "compute-requireOsLogin" {
  project    = google_project.my.project_id
  constraint = "compute.requireOsLogin"
  boolean_policy {
    enforced = false
  }
}
resource "google_compute_project_metadata" "enable-oslogin" {
  metadata = {
    enable-oslogin = "FALSE"
  }
}

# Enable service account creation
resource "google_project_organization_policy" "iam-disableServiceAccountCreation" {
  project = google_project.my.project_id
  # Disable service account creation
  constraint = "iam.disableServiceAccountCreation"
  boolean_policy {
    # Allow
    enforced = false
  }
}

# Allow service account key creation
resource "google_project_organization_policy" "iam-disableServiceAccountKeyCreation" {
  project = google_project.my.project_id
  # Disable service account key creation
  constraint = "iam.disableServiceAccountKeyCreation"
  boolean_policy {
    # Allow
    enforced = false
  }
}

# Enable Compute Engine VM instances external IP addresses
resource "google_project_organization_policy" "compute-vmExternalIpAccess" {
  project = google_project.my.project_id
  # Define allowed external IPs for VM instances
  constraint = "compute.vmExternalIpAccess"
  list_policy {
    # Allow all
    allow {
      all = true
    }
  }
}

# Enable resource location restriction
resource "google_project_organization_policy" "gcp-resourceLocations" {
  project = google_project.my.project_id
  # Define locations where location-based GCP resources can be created
  constraint = "gcp.resourceLocations"
  list_policy {
    # Allow only single region
    allow {
      values = ["in:${var.region}-locations"]
    }
  }
}
