# gke service account
module hca_gke_runner_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google-beta.target,
    vault.target = vault.target
  }

  account_id = "hca-gke-runner"
  display_name = "Service account to run GKE system pods"
  vault_path = "${local.vault_prefix}/service-accounts/gke-runner"
  roles = ["logging.logWriter", "monitoring.metricWriter", "monitoring.viewer"]
}

# sa w/permissions to use dataflow & bigquery
module hca_dataflow_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google-beta.target,
    vault.target = vault.target
  }

  account_id = "hca-dataflow-runner"
  display_name = " Service account to run HCA dataflow jobs"
  vault_path = "${local.vault_prefix}/service-accounts/hca-dataflow-runner"
  roles = ["dataflow.worker", "bigquery.jobUser", "bigquery.dataOwner"]
}

module hca_argo_runner_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google-beta.target,
    vault.target = vault.target
  }

  account_id = "hca-argo-runner"
  display_name = "Service account to run HCA's Argo workflow."
  vault_path = "${local.vault_prefix}/service-accounts/hca-argo-runner"
  roles = ["container.developer"]
}

data google_project current_project {
  provider = google-beta.target
}

resource google_service_account_iam_binding hca_workload_identity_binding {
  provider = google-beta.target

  service_account_id = module.hca_argo_runner_account.id
  role = "roles/iam.workloadIdentityUser"
  members = ["serviceAccount:${data.google_project.current_project.name}.svc.id.goog[hca/argo-runner]"]
}
