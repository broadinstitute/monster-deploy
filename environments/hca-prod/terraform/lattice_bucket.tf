module lattice-staging-storage {
  source                          = "../../../templates/terraform/staging-storage"
  area_name                       = "lattice"
  project_name                    = local.prod_project_name
  external_writer_sa_account_name = "lattice-prod-writer"
  dev_vault_prefix                = local.prod_vault_prefix
  tdr_repo_email                  = local.prod_repo_email
  hca_dataflow_email              = module.hca_dataflow_account.email
}
