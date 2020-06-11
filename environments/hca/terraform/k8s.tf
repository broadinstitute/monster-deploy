# k8s
# Provision a cluster for running hca services.
module master {
  source = "/templates/k8s-master"
  providers = {
    google.target = google-beta.target
  }
  dependencies = [module.enable_services, module.k8s_network]

  name = "hca-cluster"
  location = "us-central1-c"

  network = module.k8s_network.network_link
  subnetwork = module.k8s_network.subnet_links[0]

  restrict_master_access = false

  vault_path = "${local.dev_vault_prefix}/gke"
}

module node_pool {
  source = "/templates/k8s-node-pool"
  providers = {
    google.target = google-beta.target
  }
  dependencies = [module.enable_services, module.master]

  name = "hca-node-pool"
  master_name = module.master.name
  location = "us-central1-c"

  node_count = 3
  machine_type = "n1-standard-2"
  disk_size_gb = 30

  autoscaling = null
  taints = null
  service_account_email = module.hca_gke_runner_account.email
}

# gke service account
module hca_gke_runner_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google-beta.target,
    vault.target = vault.target
  }

  account_id = "hca-gke-runner"
  display_name = "Service account to run GKE system pods"
  vault_path = "${local.dev_vault_prefix}/service-accounts/gke-runner"
  roles = ["logging.logWriter", "monitoring.metricWriter", "monitoring.viewer"]
}
