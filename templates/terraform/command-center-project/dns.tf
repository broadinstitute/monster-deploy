###
## DO NOT TEAR THIS DOWN.
##
## Every time this resource gets recreated in Google,
## BITS has to manually reconfigure their routing rules.
###
resource google_dns_managed_zone dns_zone {
  provider = google.target
  name = local.dns_zone_name
  dns_name = "${local.dns_zone_name}.broadinstitute.org."
}

module dns_names {
  source = "/templates/dns"
  providers = {
    google.ip = google.target,
    google.dns = google.target
  }
  dependencies = [module.enable_services]
  zone_gcp_name = google_dns_managed_zone.dns_zone.name
  zone_dns_name = google_dns_managed_zone.dns_zone.dns_name
  dns_names = ["argo","grafana"]
}
