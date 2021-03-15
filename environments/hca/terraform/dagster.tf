resource "google_project_iam_custom_role" "argo_access" {
  provider = google-beta.target

  role_id     = "argoworkflows.user"
  title       = "Argo Workflows API User"
  description = "Ability to interact with the REST API exposed by a Kubernetes cluster running Argo Workflows UI."
  permissions = [
    "container.thirdPartyObjects.create",
    "container.thirdPartyObjects.delete",
    "container.thirdPartyObjects.get",
    "container.thirdPartyObjects.list",
    "container.thirdPartyObjects.update",
  ]
}

module hca_dagster_runner_account {
  source = "../../../templates/terraform/google-sa"
  providers = {
    google.target = google-beta.target,
    vault.target  = vault.target
  }

  account_id   = "hca-dagster-runner"
  display_name = "Service account to run HCA's Dagster pipelines."
  vault_path   = "${local.dev_vault_prefix}/service-accounts/hca-dagster-runner"
  roles = [
    "dataflow.developer",
    "compute.viewer",
    "bigquery.jobUser",
    "bigquery.dataOwner",
  ]
}

resource "google_project_iam_member" "argo_access_member" {
  provider = google-beta.target

  role   = google_project_iam_custom_role.argo_access.id
  member = "serviceAccount:${module.hca_dagster_runner_account.email}"
}

resource "google_service_account_iam_binding" "kubernetes_role_binding" {
  provider = google-beta.target

  service_account_id = module.hca_dagster_runner_account.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${local.dev_project_name}.svc.id.goog[dagster/monster-dagster]"
  ]
}
