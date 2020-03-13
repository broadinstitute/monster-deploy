variable env {
  type = string
  description = "Environment of infrastructure (dev or prod)."
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
  vault_prefix = "secret/dsde/monster/${var.env}"
}
