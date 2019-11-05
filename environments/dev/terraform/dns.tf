###
## DO NOT TEAR THIS DOWN.
##
## Every time this resource gets recreated in Google,
## BITS has to manually reconfigure their routing rules.
###
resource "google_dns_managed_zone" "dns_zone" {
  provider = "google"
  name = "monster-dev"
  dns_name = "monster-dev.broadinstitute.org."
}
