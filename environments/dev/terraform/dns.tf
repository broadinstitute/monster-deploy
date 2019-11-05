resource "google_dns_managed_zone" "dns_zone" {
  provider = "google"
  name = "monster-dev"
  dns_name = "monster-dev.broadinstitute.org."
}
