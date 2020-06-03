data google_dns_managed_zone dev_zone {
  provider = google-beta.dev-core
  name = "monster-dev"
}

module dns_names {
  source = "/templates/dns"
  providers = {
    google.ip = google-beta.target,
    google.dns = google-beta.dev-core
  }
  dependencies = [module.enable_services]
  zone_gcp_name = data.google_dns_managed_zone.dev_zone.name
  zone_dns_name = data.google_dns_managed_zone.dev_zone.dns_name
  dns_names = ["hca-argo", "hca-grafana"]
}
