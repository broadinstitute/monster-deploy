variable is_production {
  type        = bool
  description = "If true, production-level logging etc. will be enabled"
}

variable k8s_cluster_size {
  type        = number
  description = "Number of nodes to run in the GKE cluster."
}

variable k8s_machine_type {
  type        = string
  description = "Machine type to use in the GKE cluster."
}

variable db_tier {
  type        = string
  description = "Machine tier for the Cloud SQL proxy instance backing command-center services."
}

locals {
  vault_prefix  = "secret/dsde/monster/${var.is_production ? "prod" : "dev"}/command-center"
  dns_zone_name = "monster-${var.is_production ? "prod" : "dev"}"
}
