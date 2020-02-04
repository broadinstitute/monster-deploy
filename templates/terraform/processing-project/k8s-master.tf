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

  vault_path = "${var.vault_prefix}/gke"
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

  node_count = var.k8s_static_cluster_size
  machine_type = "g1-small"
  disk_size_gb = 10

  autoscaling = null
  taints = null
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
  machine_type = var.k8s_scaled_machine_type
  disk_size_gb = 10

  autoscaling = {
    min_node_count = 0
    max_node_count = var.k8s_scaled_cluster_max_size
  }

  taints = [{
    key = "pool_type"
    value = "argo_autoscaling"
    effect = "NO_EXECUTE"
  }]
}
