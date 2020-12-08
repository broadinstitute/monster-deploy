variable name_prefix {
  type        = string
  description = "Prefix to add before cloudSQL resource names."
}

variable postgres_version {
  type        = string
  description = "The version of PostgreSQL to use."
  default     = "POSTGRES_9_6"
}

variable cpu {
  type        = number
  description = "Number of processors allocated to the instance."
}

variable ram {
  type        = number
  description = "Memory allocated to the instance in MiB."
}

variable labels {
  type        = map(string)
  description = "A set of key/value user label pairs to assign to the instance."
}

variable db_names {
  type        = list(string)
  description = "List of database names."
}

variable user_names {
  type        = list(string)
  description = "List of user names."
}

variable vault_prefix {
  type        = string
  description = "Path to prepend before a vault path for this module's secrets."
}

variable dependencies {
  type        = any
  default     = []
  description = "Work-around for Terraform 0.12's lack of support for 'depends_on' in custom modules."
}
