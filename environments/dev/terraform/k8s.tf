###
## Shared k8s cluster for running experiments.
##
## We generate a helper script for running 'kubectl' against
## the cluster, so the module remains the sole source of truth
## for cluster name / project / region. The script should be
## checked into source control to avoid noisy terraform diffs.
###
module "experiment_k8s" {
  source = "github.com/broadinstitute/terraform-shared.git//terraform-modules/k8s?ref=k8s-0.4.0-tf-0.12"
  dependencies = [module.enable_services]
  providers = {
    google = "google-beta"
  }
  location = "us-central1-c"

  cluster_name = "experiments-k8s-cluster"
  k8s_version = "1.14."

  cluster_network = google_compute_network.k8s_network.name
  cluster_subnetwork = google_compute_subnetwork.k8s_subnetwork.name

  node_pool_count = 2
  node_pool_machine_type = "n1-standard-2"
  node_pool_disk_size_gb = 10

  # CIDRs of networks allowed to talk to the k8s master.
  master_authorized_network_cidrs = [
    "69.173.64.0/19",
    "69.173.96.0/20",
    "69.173.112.0/21",
    "69.173.120.0/22",
    "69.173.124.0/23",
    "69.173.126.0/24",
    "69.173.127.0/25",
    "69.173.127.128/26",
    "69.173.127.192/27",
    "69.173.127.224/30",
    "69.173.127.228/32",
    "69.173.127.230/31",
    "69.173.127.232/29",
    "69.173.127.240/28"
  ]

  enable_private_nodes = true
  enable_private_endpoint = false
  private_master_ipv4_cidr_block = "10.0.82.0/28"

  enable_workload_identity = true
}
resource "local_file" "experiment_k8s_kubectl" {
  filename = "${dirname(abspath(path.module))}/k8s/experiments-k8s-cluster/kubectl"
  file_permission = "0754"
  content = <<SCRIPT
#!/usr/bin/env bash

gcloud container clusters get-credentials \
  --project=broad-dsp-monster-dev \
  --zone=us-central1-c \
  experiments-k8s-cluster

kubectl --context=gke_broad-dsp-monster-dev_us-central1-c_experiments-k8s-cluster "$${@}"
SCRIPT
}
resource "null_resource" "experiment_k8s_psp" {
  triggers = {
    cluster_name = module.experiment_k8s.cluster_name,
    cluster_endpoint = module.experiment_k8s.cluster_endpoint,
    kubectl_script = local_file.experiment_k8s_kubectl.content
  }

  provisioner "local-exec" {
    working_dir = "${dirname(abspath(path.module))}/k8s"
    command = "./experiments-k8s-cluster/kubectl apply -f ./init-configs"
  }
}
