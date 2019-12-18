# Create the top-level network.
resource google_compute_network network {
  provider = google.target
  name = var.name
  auto_create_subnetworks = false
  depends_on = [var.dependencies]
}

# Create subnetworks under the main network.
# We reuse the name of the main network for simplicity;
# names only need to be unique per parent network/region.
resource google_compute_subnetwork subnetworks {
  provider = google.target
  count = length(var.subnets)

  name = var.name
  network = google_compute_network.network.self_link
  ip_cidr_range = var.subnets[count.index].cidr
  private_ip_google_access = true

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? ["Placeholder to force one iteration"] : []
    content {
      aggregation_interval = "INTERVAL_10_MIN"
      flow_sampling = 0.5
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
}

# Set up NAT through a fixed set of IPs so programs running in the network
# can talk to the Internet (e.g. to pull Docker images from DockerHub).
resource google_compute_router router {
  provider = google.target
  name = "${var.name}-router"
  network = google_compute_network.network.self_link

  bgp {
    asn = 64514
  }
}
resource google_compute_address nat_addresses {
  provider = google.target
  count = 2
  name = "${var.name}-nat-${count.index}"
  depends_on = [var.dependencies]
}
resource google_compute_router_nat nat {
  provider = google.target
  name = "${var.name}-nat"
  router = google_compute_router.router.name
  nat_ips = google_compute_address.nat_addresses[*].self_link
  nat_ip_allocate_option = "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
