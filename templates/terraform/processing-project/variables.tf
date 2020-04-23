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

variable create_results_bucket {
  type = bool
  description = "If true, create a dedicated bucket for delivery of ingest outputs outside of the Data Repo."
  default = false
}

variable result_reader_groups {
  type = list(string)
  description = "Email addresses of google groups that should be able to read from the results bucket."
  default = []
}

variable deletion_age_days {
  type = number
  description = "The number of days to wait before deleting files in the staging bucket."
}

variable vault_prefix {
  type = string
  description = "Path prefix for secrets written to Vault."
}

variable command_center_argo_account_email {
  type = string
  description = "Email which is tied to the command-center Argo service account."
}

variable jade_repo_email {
  type = string
  description = "Email for the service account running the Jade Repo."
}
