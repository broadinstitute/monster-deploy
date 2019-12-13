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

variable k8s_zone {
  type = string
  description = "Zone within `region` where GKE clusters should run"
}
