provider google-beta {
  project = "broad-dsp-monster-clingen-dev"
  region = "us-central1"
  alias = "clinvar"
}

module clinvar {
  source = "/templates/processing-project"
  providers = {
    google.target = google-beta.clinvar
  }

  project_name = "broad-dsp-monster-clingen-dev"
  is_production = false
  region = "us-central1"
  k8s_zone = "a"
  kubeconfig_path = "${local.processing_kubeconfig_dir}/clinvar"
  k8s_scaled_cluster_max_size = 3
  k8s_scaled_machine_type = "n1-standard-1"
  k8s_static_cluster_size = 2
  access_groups = ["clingendevs@broadinstitute.org"]
  deletion_age_days = 30
}
