# Provision a cluster for running "core" services.
# For example, this cluster will run Airflow, Argo CD, and the Argo controllers.
module core_k8s_master {
  source = "/templates/k8s-master"
  providers = {
    google.target = google.target
  }
  dependencies = [module.enable_services, module.k8s_network]

  name = "monster-core-cluster"
  location = "us-central1-c"

  network = module.k8s_network.network_link
  subnetwork = module.k8s_network.subnet_links[0]
}
module core_k8s_node_pool {
  source = "/templates/k8s-node-pool"
  providers = {
    google.target = google.target
  }
  dependencies = [module.enable_services, module.core_k8s_master]

  name = "monster-core-node-pool"
  master_name = module.core_k8s_master.name
  location = "us-central1-c"

  node_count = var.k8s_cluster_size
  machine_type = var.k8s_machine_type
  disk_size_gb = 10

  autoscaling = null
}

# Write a kubeconfig for the cluster to disk, for use downstream.
# Inspired by https://ahmet.im/blog/authenticating-to-gke-without-gcloud/
resource local_file core_kubeconfig {
  filename = var.kubeconfig_path
  content = <<EOF
apiVersion: v1
kind: Config
current-context: core-context
contexts: [{name: core-context, context: {cluster: ${module.core_k8s_master.name}, user: local-user}}]
users: [{name: local-user, user: {auth-provider: {name: gcp}}}]
clusters:
- name: ${module.core_k8s_master.name}
  cluster:
    server: "https://${module.core_k8s_master.endpoint}"
    certificate-authority-data: "${module.core_k8s_master.ca_certificate}"
EOF
}
