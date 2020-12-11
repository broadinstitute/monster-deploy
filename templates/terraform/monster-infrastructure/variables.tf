variable is_production {
  type        = bool
  description = "true -> prod, false -> dev."
  default     = false
}

variable cluster_size {
  type        = number
  description = "Size of k8s cluster for command center."
}

variable machine_type {
  type        = string
  description = "Machine type of k8s cluster for command center."
}

variable db_tier {
  type        = string
  description = "Database specification for command center."
}

locals {
  env             = var.is_production ? "prod" : "dev"
  jade_repo_email = var.is_production ? "terra-data-repository@broad-datarepo-terra-prod.iam.gserviceaccount.com" : "jade-k8-sa@broad-jade-dev.iam.gserviceaccount.com"
  vault_prefix    = "secret/dsde/monster/${local.env}"
}
