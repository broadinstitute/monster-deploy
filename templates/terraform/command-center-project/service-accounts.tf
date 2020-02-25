module command_center_gke_runner_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target,
    vault.target = vault.target
  }

  account_id = "command-center-gke-runner"
  display_name = "Service account to run GKE system pods"
  vault_path = "${local.vault_prefix}/service-accounts/gke-runner"
  roles = ["logging.logWriter", "monitoring.metricWriter", "monitoring.viewer"]
}

module clinvar_argo_runner_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target,
    vault.target = vault.target
  }

  account_id = "clinvar-argo-runner"
  display_name = "Service account to run ClinVar's Argo workflow."
  vault_path = "${local.vault_prefix}/service-accounts/clinvar-argo-runner"
  roles = ["container.developer"]
}

data google_project current_project {
  provider = google.target
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = module.clinvar_argo_runner_account.email
  role = "roles/iam.workloadIdentityUser"

  members = ["serviceAccount:${data.google_project.current_project.name}.svc.id.goog[clinvar/argo-runner]"]
}