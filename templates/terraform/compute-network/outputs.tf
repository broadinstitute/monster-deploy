output network_link {
  value = google_compute_network.network.self_link
}

output subnet_links {
  value = google_compute_subnetwork.subnetworks[*].self_link
}
