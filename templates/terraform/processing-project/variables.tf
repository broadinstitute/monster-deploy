variable project_name {
  type = string
  description = "Name of the processing project"
}

variable is_production {
  type = bool
  description = "If true, production-level logging etc. will be enabled"
}

variable region {
  type = string
  description = "Region where processing should run"
}

variable k8s_static_cluster_size {
  type = number
  description = "Number of nodes to run in the static processing k8s cluster."
}

variable k8s_static_machine_type {
  type = string
  description = "Machine type to use in the static processing k8s cluster."
}

variable k8s_scaled_cluster_max_size {
  type = number
  description = "Maximum number of nodes to run in the autoscaled processing k8s cluster."
}

variable k8s_scaled_machine_type {
  type = string
  description = "Machine type to use in the autoscaled processing k8s cluster."
}

variable k8s_zone {
  type = string
  description = "Zone within `region` where GKE clusters should run"
}
