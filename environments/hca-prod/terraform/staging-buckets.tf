module lattice-staging-storage {
  source                          = "../../../templates/terraform/staging-storage"
  area_name                       = "lattice"
  project_name                    = local.prod_project_name
  project_id                      = local.prod_project_id
  external_writer_sa_account_name = "lattice-prod-writer"
  vault_prefix                    = local.prod_vault_prefix
  tdr_repo_email                  = local.prod_repo_email
  hca_dataflow_email              = module.hca_dataflow_account.email
}

module lantern-staging-storage {
  source                          = "../../../templates/terraform/staging-storage"
  area_name                       = "lantern"
  project_name                    = local.prod_project_name
  project_id                      = local.prod_project_id
  external_writer_sa_account_name = "lantern-prod-writer"
  vault_prefix                    = local.prod_vault_prefix
  tdr_repo_email                  = local.prod_repo_email
  hca_dataflow_email              = module.hca_dataflow_account.email
}
