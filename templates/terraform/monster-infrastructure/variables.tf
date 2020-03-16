variable is_production {
  type = bool
  description = "True -> prod, false -> dev."
  default = false
}

variable cluster_size {
  type = number
  description = "Size of k8s cluster for command center."
}

variable machine_type {
  type = string
  description = "Machine type of k8s cluster for command center."
}

variable db_tier {
  type = string
  description = "Database specification for command center."
}

locals {
  env = var.is_production ? "prod" : "dev"
  vault_prefix = "secret/dsde/monster/${local.env}"

}
