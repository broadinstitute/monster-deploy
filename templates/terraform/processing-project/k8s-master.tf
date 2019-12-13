###
## k8s cluster for ad-hoc processing during ingest.
###
module processing_k8s_master {
  source = "/templates/k8s-master"
  providers = {
    google.target = google.target
  }
  dependencies = [module.enable_services, module.k8s_network]

  name = "monster-processing-cluster"
  location = "${var.region}-${var.k8s_zone}"

  network = module.k8s_network.network_link
  subnetwork = module.k8s_network.subnet_links[0]
}
