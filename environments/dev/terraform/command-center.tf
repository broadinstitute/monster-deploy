provider google-beta {
  project = "broad-dsp-monster-dev"
  region = "us-central1"
  alias = "command-center"
}

module command_center {
  # NOTE: This path is where we expect the template to be mounted
  # within the Docker image we run in init.sh, not where we expect
  # it to be located in the git repo.
  source = "/templates/command-center-project"
  providers = {
    google.target = google-beta.command-center
  }

  is_production = false
  dns_zone_name = "monster-dev"
  k8s_cluster_size = 2
  k8s_machine_type = "n1-standard-2"
  kubeconfig_path = "${var.kubeconfig_dir_path}/command-center"
}
