# Create a GKE master for running ad-hoc processing.
# Node pools will be spun up/down as part of the ingest workflow.
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
module processing_k8s_static_node_pool {
  source = "/templates/k8s-node-pool"
  providers = {
    google.target = google.target
  }
  dependencies = [module.enable_services, module.processing_k8s_master]

  name = "monster-processing-static-node-pool"
  master_name = module.processing_k8s_master.name
  location = "${var.region}-${var.k8s_zone}"

  node_count = var.k8s_static_cluster_size # TODO hard code this?
  machine_type = var.k8s_static_machine_type # TODO hard code this?
  disk_size_gb = 10 # TODO what should this be?

  autoscaling = null
}

module processing_k8s_scaled_node_pool {
  source = "/templates/k8s-node-pool"
  providers = {
    google.target = google.target
  }
  dependencies = [module.enable_services, module.processing_k8s_master]

  name = "monster-processing-scaled-node-pool"
  master_name = module.processing_k8s_master.name
  location = "${var.region}-${var.k8s_zone}"

  node_count = null

  autoscaling = {
    min_node_count = 0
    max_node_count = var.k8s_scaled_cluster_max_size
  }
  machine_type = var.k8s_scaled_machine_type
}