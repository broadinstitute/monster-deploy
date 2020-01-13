# Provision a cluster for running "command center" services.
# For example, this cluster will run Airflow, Argo CD, and the Argo controllers.
module master {
  source = "/templates/k8s-master"
  providers = {
    google.target = google.target
  }
  dependencies = [module.enable_services, module.k8s_network]

  name = "command-center-cluster"
  location = "us-central1-c"

  network = module.k8s_network.network_link
  subnetwork = module.k8s_network.subnet_links[0]
}
module node_pool {
  source = "/templates/k8s-node-pool"
  providers = {
    google.target = google.target
  }
  dependencies = [module.enable_services, module.master]

  name = "command-center-node-pool"
  master_name = module.master.name
  location = "us-central1-c"

  node_count = var.k8s_cluster_size
  machine_type = var.k8s_machine_type
  disk_size_gb = 10

  autoscaling = null
}

# Write a kubeconfig for the cluster to disk, for use downstream.
# Inspired by https://ahmet.im/blog/authenticating-to-gke-without-gcloud/
resource local_file kubeconfig {
  filename = var.kubeconfig_path
  content = module.master.kubeconfig
}
