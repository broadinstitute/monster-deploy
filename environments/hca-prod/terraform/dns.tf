data google_dns_managed_zone prod_zone {
  provider = google-beta.prod-core
  name = "monster-prod"
}

module dns_names {
  source = "../../../templates/terraform/dns"
  providers = {
    google.ip = google-beta.target,
    google.dns = google-beta.prod-core
  }
  dependencies = [module.enable_services]
  zone_gcp_name = data.google_dns_managed_zone.prod_zone.name
  zone_dns_name = data.google_dns_managed_zone.prod_zone.dns_name
  dns_names = ["hca-argo", "hca-grafana"]
}
