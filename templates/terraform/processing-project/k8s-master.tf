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

# Write a kubeconfig for the cluster to disk, for use downstream.
# Inspired by https://ahmet.im/blog/authenticating-to-gke-without-gcloud/
resource local_file processing_kubeconfig {
  filename = var.kubeconfig_path
  content = module.processing_k8s_master.kubeconfig
}
