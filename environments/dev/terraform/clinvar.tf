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
  k8s_scaled_cluster_max_size = 3
  k8s_scaled_machine_type = "n1-standard-1"
  k8s_static_cluster_size = 2
  reader_groups = ["clingendevs@broadinstitute.org"]
  deletion_age_days = null # FIXME: Reset back to 30 after we set up prod.
  vault_prefix = "${local.vault_prefix}/processing-projects/clinvar"
}
