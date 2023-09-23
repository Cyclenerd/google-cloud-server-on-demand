# Store Cloud Source URL in file
# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "sourcerepo-url" {
  content  = <<-EOF
    #!/usr/bin/env bash
    # With Terraform generated script !!! Do not change manually !!!
    git remote remove cloudsource 2> '/dev/null'
    git remote add    cloudsource '${google_sourcerepo_repository.repo.url}'
    git remote show   cloudsource
  EOF
  filename = "sourcerepo-url.sh"
}

# Store Terraform variables as Shell variables
resource "local_file" "variables" {
  content  = <<-EOF
    #!/usr/bin/env bash
    # With Terraform generated variables file !!! Do not change manually !!!
    export MY_PROJECT='${google_project.my.project_id}'
    export MY_PUBSUB_TOPIC_CREATE='${google_pubsub_topic.create.name}'
    export MY_PUBSUB_TOPIC_TEMP='${google_pubsub_topic.temp.name}'
    export MY_DNS_DOMAIN='${google_dns_managed_zone.dns.dns_name}'
    export MY_EXPIRES='${var.expires}'
    export MY_MAX_VMS='${var.max-vms}'
  EOF
  filename = "variables.sh"
}

# Store Terraform variables as Shell variables
resource "local_file" "dns-servers" {
  content  = <<-EOF
    Add all of the name servers to your DNS (registrar setup) as type NS:
    ${google_dns_managed_zone.dns.name_servers[0]}
    ${google_dns_managed_zone.dns.name_servers[1]}
    ${google_dns_managed_zone.dns.name_servers[2]}
    ${google_dns_managed_zone.dns.name_servers[3]}
  EOF
  filename = "dns-name-servers.txt"
}

# Store service account private key for Raspberry Pi
resource "local_file" "pi-key" {
  content  = base64decode(google_service_account_key.pi.private_key)
  filename = "pi-private-key.json"
}