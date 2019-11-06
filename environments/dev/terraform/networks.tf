###
## Network and subnetwork for the nodes of our test k8s cluster.
##
## Includes a NAT router so private services on the network can
## interact with the outside world as a static IP.
##
## NOTE: The subnetwork purposefully disables flow logs so we don't
## overwhelm the AppSec powers-that-be with spam.
###
resource "google_compute_network" "k8s_network" {
  provider = "google-beta"

  name = "test-k8s-network"
  auto_create_subnetworks = false
  depends_on = [module.enable_services]
}
resource "google_compute_subnetwork" "k8s_subnetwork" {
  provider = "google-beta"

  name = "test-k8s-subnetwork"
  network = google_compute_network.k8s_network.self_link
  ip_cidr_range = "10.0.0.0/22"
  private_ip_google_access = true
  enable_flow_logs = false
}
resource "google_compute_router" "k8s_router" {
  provider = "google"

  name = "k8s-network-router"
  network = google_compute_network.k8s_network.self_link

  bgp {
    asn = 64514
  }
}
resource "google_compute_address" "k8s_nat_address" {
  provider = "google"

  count = 2
  name = "k8s-nat-address-${count.index}"
  depends_on = [module.enable_services]
}
resource "google_compute_router_nat" "k8s_nat" {
  provider = "google"

  name = "k8s-network-nat"
  router = google_compute_router.k8s_router.name
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = google_compute_address.k8s_nat_address[*].self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
