variable is_production {
  type = bool
  description = "true -> prod, false -> dev."
  default = false
}

variable k8s_cluster_size {
  type = number
  description = "Size of k8s cluster for command center."
  default = 3
}

variable k8s_machine_type {
  type = string
  description = "Machine type of k8s cluster for command center."
  default = "n1-standard-4"
}

locals {
  project_name = "broad-dsp-monster-hca-${var.is_production ? "prod" : "dev"}"
  vault_prefix = "secret/dsde/monster/${var.is_production ? "prod" : "dev"}/ingest/hca"
  jade_repo_email = var.is_production ? "terra-data-repository@broad-datarepo-terra-prod.iam.gserviceaccount.com" : "jade-k8-sa@broad-jade-dev.iam.gserviceaccount.com"
}
