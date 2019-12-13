output name {
  value = google_container_cluster.master.name
}

output endpoint {
  value = google_container_cluster.master.endpoint
}

output ca_certificate {
  value = google_container_cluster.master.master_auth[0].cluster_ca_certificate
}
