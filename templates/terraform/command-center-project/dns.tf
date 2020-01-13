###
## DO NOT TEAR THIS DOWN.
##
## Every time this resource gets recreated in Google,
## BITS has to manually reconfigure their routing rules.
###
resource google_dns_managed_zone dns_zone {
  provider = google.target
  name = var.dns_zone_name
  dns_name = "${var.dns_zone_name}.broadinstitute.org."
}
